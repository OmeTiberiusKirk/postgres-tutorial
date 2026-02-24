# Chapter 2. The SQL Language

## Concepts

PostgreSQL เป็นระบบจัดการฐานข้อมูลเชิงสัมพันธ์ (RDBMS) ซึ่งหมายความว่า เป็นระบบที่ จัดการข้อมูลที่จัดเก็บในรูปแบบความสัมพันธ์

Relation คือคำศัพท์ทางคณิตศาสตร์ ที่โดยพื้นฐานแล้วหมายถึง ตาราง (table)

| เชิงคณิตศาสตร์ | เชิงฐานข้อมูล (SQL) |
| -------------- | ------------------- |
| Relation       | Table               |
| Tuple          | Row / Record        |
| Attribute      | Column              |
| Domain         | Data Type           |

**table** คือชุดของ **rows** ที่ถูกกำหนดชื่อ<br>
**row** ใน **table** จะมีชุด **columns** ที่ถูกกำหนดชื่อ เช่นกัน<br>
**column** ก็จะเป็นชนิดข้อมูลที่กำหนดไว้โดยเฉพาะ เช่น integer, varchar, date, boolean

### ตัวอย่าง

#### ตารางชื่อ User

| id  | name | age |
| --- | ---- | --- |
| 1   | A    | 20  |
| 2   | B    | 25  |
| 3   | C    | 30  |

ตารางต่างๆ จะถูกจัดกลุ่มเป็นฐานข้อมูล และกลุ่มของฐานข้อมูลที่ จัดการโดยอินสแตนซ์เซิร์ฟเวอร์ PostgreSQL เดียว จะประกอบเป็นคลัสเตอร์ฐานข้อมูล

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

## Creating a New Table

คุณสามารถสร้างตารางใหม่ได้โดยระบุชื่อตาราง พร้อมทั้งชื่อคอลัมน์และชนิดของข้อมูล:

```
CREATE TABLE weather (
  city varchar(80),
  temp_lo int, -- low temperature
  temp_hi int, -- high temperature
  prcp real, -- precipitation
  date date
);
```

สามารถป้อนคำสั่งนี้ลงใน psql โดยเว้นวรรคบรรทัดได้ psql จะรับรู้ว่าคำสั่งยังไม่สิ้นสุด จนกว่าจะพบเครื่องหมายเซมิโคลอน<br>

ช่องว่าง (เช่น ช่องว่าง แท็บ และขึ้นบรรทัดใหม่) สามารถใช้ได้อย่างอิสระในคำสั่ง SQL<br>

เครื่องหมายขีดสองขีด (“--”) ใช้สำหรับใส่ข้อความ<br>

SQL ไม่คำนึงถึงตัวพิมพ์ใหญ่เล็ก สำหรับคำหลักและตัวระบุ ยกเว้นในกรณีที่ตัวระบุถูกใส่เครื่องหมาย เช่น `select * from "PostgreSQL"`
