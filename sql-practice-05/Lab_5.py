from neo4j import GraphDatabase
import random

# --------- ПАРАМЕТРЫ ДЛЯ ВАРИАНТА 5 ---------

TOTAL_NODES = 50                     # всего вершин
VERTEX_LABELS = ["A", "B", "C", "D", "E", "F", "G"]  # 7 меток вершин
REL_LABELS = ["R1", "R2", "R3"]      # 3 типа ребер
LINK_CHANCE = 0.05                   # вероятность создания ребра


class GraphBuilder:
    def __init__(self, uri: str, user: str, password: str):
        self._driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self._driver.close()

    # ---------- ВНУТРЕННИЕ ТРАНЗАКЦИИ ----------

    @staticmethod
    def _tx_wipe(tx):
        # Чистим базу одним запросом
        tx.run("MATCH (n) DETACH DELETE n")

    @staticmethod
    def _tx_create_node(tx, lbl: str, node_name: str):
        cypher = f"CREATE (n:{lbl} {{name: $n}})"
        tx.run(cypher, n=node_name)

    @staticmethod
    def _tx_create_rel(tx, src_name: str, dst_name: str, rel_lbl: str):
        cypher = (
            "MATCH (s {name: $s_name}), (t {name: $t_name}) "
            f"CREATE (s)-[:{rel_lbl}]->(t)"
        )
        tx.run(cypher, s_name=src_name, t_name=dst_name)

    @staticmethod
    def _tx_get_isolated(tx):
        cypher = (
            "MATCH (n) "
            "WHERE size( (n)--() ) = 0 "
            "RETURN n.name AS n_name, head(labels(n)) AS lbl "
            "ORDER BY n_name"
        )
        return list(tx.run(cypher))

    @staticmethod
    def _tx_get_candidates(tx, target_label: str):
        """
        Кандидаты для соединения:
        - имеют метку target_label
        - связаны с вершиной метки A
        - не имеют соседей с той же меткой
        """
        cypher = (
            "MATCH (a:A)-[]-(c) "
            "WHERE $lab IN labels(c) "
            "WITH DISTINCT c "
            "WHERE size([x IN nodes((c)--()) WHERE $lab IN labels(x)]) = 0 "
            "RETURN c.name AS name"
        )
        return list(tx.run(cypher, lab=target_label))

    # ---------- ПУБЛИЧНЫЕ МЕТОДЫ ----------

    def reset_graph(self):
        """Удалить весь граф."""
        with self._driver.session() as session:
            session.execute_write(self._tx_wipe)

    def generate_graph(self):
        """
        1) создаёт TOTAL_NODES вершин с произвольными метками из VERTEX_LABELS
        2) между некоторыми парами вершин создаёт случайные ориентированные ребра
        """
        with self._driver.session() as session:
            node_names = []

            # --- создаём вершины ---
            for idx in range(TOTAL_NODES):
                label = random.choice(VERTEX_LABELS)
                name = str(idx)          # "0".."49"
                session.execute_write(self._tx_create_node, label, name)
                node_names.append(name)

            # --- создаём ребра ---
            # пробегаем только по парам (i, j), i < j, а направление выбираем случайно
            for i in range(TOTAL_NODES):
                for j in range(i + 1, TOTAL_NODES):
                    if random.random() <= LINK_CHANCE:
                        rel_type = random.choice(REL_LABELS)

                        if random.random() < 0.5:
                            src, dst = node_names[i], node_names[j]
                        else:
                            src, dst = node_names[j], node_names[i]

                        session.execute_write(
                            self._tx_create_rel,
                            src,
                            dst,
                            rel_type
                        )

    def attach_isolated(self):
        """
        Реализация п.2.2:
        для каждой изолированной вершины ищем подходящую вершину той же метки
        и создаём к ней ребро первого типа из REL_LABELS.
        """
        with self._driver.session() as session:
            isolated = session.execute_read(self._tx_get_isolated)

            for row in isolated:
                node_name = row["n_name"]
                node_label = row["lbl"]
                if node_label is None:
                    continue

                candidates = session.execute_read(
                    self._tx_get_candidates,
                    target_label=node_label
                )

                if not candidates:
                    continue

                # берём первого кандидата
                target_name = candidates[0]["name"]

                session.execute_write(
                    self._tx_create_rel,
                    node_name,
                    target_name,
                    REL_LABELS[0]
                )


if __name__ == "__main__":
    # ---- НАСТРОЙКА ПОДКЛЮЧЕНИЯ ----
    URI = "bolt://localhost:7687"
    USER = "neo4j"
    PASSWORD = "123"

    gb = GraphBuilder(URI, USER, PASSWORD)

    print("Шаг 1: очищаю текущий граф...")
    gb.reset_graph()

    print("Шаг 2: генерирую вершины и рёбра...")
    gb.generate_graph()

    print("Шаг 3: подключаю изолированные вершины...")
    gb.attach_isolated()

    gb.close()
    print("Готово.")
