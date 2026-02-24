# Chapter 2. The SQL Language

## Concepts

PostgreSQL เป็นระบบจัดการฐานข้อมูลเชิงสัมพันธ์ (RDBMS) ซึ่งหมายความว่า เป็นระบบที่ จัดการข้อมูลที่จัดเก็บในรูปแบบความสัมพันธ์

Relation คือคำศัพท์ทางคณิตศาสตร์ ที่โดยพื้นฐานแล้วหมายถึง ตาราง (table)

- **table** คือชุดของ **rows** ที่ถูกกำหนดชื่อ
- **row** ใน **table** จะมีชุด **columns** ที่ถูกกำหนดชื่อ เช่นกัน
- **column** ก็จะเป็นชนิดข้อมูลที่กำหนดไว้โดยเฉพาะ เช่น integer, varchar, date, boolean

| เชิงคณิตศาสตร์ | เชิงฐานข้อมูล (SQL) |
| -------------- | ------------------- |
| Relation       | Table               |
| Tuple          | Row / Record        |
| Attribute      | Column              |
| Domain         | Data Type           |

### ตัวอย่าง

#### ตารางชื่อ User

| id  | name | age |
| --- | ---- | --- |
| 1   | A    | 20  |
| 2   | B    | 25  |
| 3   | C    | 30  |

ตารางต่างๆ จะถูกจัดกลุ่มเป็นฐานข้อมูล และกลุ่มของฐานข้อมูลที ่จัดการโดยอินสแตนซ์เซิร์ฟเวอร์ PostgreSQL เดียว จะประกอบเป็นคลัสเตอร์ฐานข้อมูล

- PostgreSQL Server Instance
  - Database Cluster
    - Database: app_db
      - Table: users
      - Table: orders
      - Table: products
    - Database: analytics_db
      - Table: events
      - Table: metrics
    - Database: test_db
      - Table: mock_users
      - Table: logs
