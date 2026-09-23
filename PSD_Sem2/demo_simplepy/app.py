import os
import psycopg2

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "testdb")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "secretpassword")
DB_PORT = os.getenv("DB_PORT", "5432")


def main():
    print("Подключение к PostgreSQL...")
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        port=DB_PORT,
    )
    cursor = conn.cursor()

    print("Выполнение запроса: SELECT * FROM users;\n")
    cursor.execute("SELECT id, name, email FROM users;")
    rows = cursor.fetchall()

    print(f"{'ID':<4} | {'Имя':<12} | {'Email'}")
    print("-" * 35)
    for row in rows:
        print(f"{row[0]:<4} | {row[1]:<12} | {row[2]}")

    cursor.close()
    conn.close()
    print("\nСоединение успешно закрыто.")


if __name__ == "__main__":
    main()