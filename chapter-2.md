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

เครื่องหมาย double dash (“--”) ใช้สำหรับใส่ข้อความ<br>

SQL ไม่คำนึงถึงตัวพิมพ์ใหญ่เล็ก สำหรับคำหลักและตัวระบุ ยกเว้นในกรณีที่ตัวระบุถูกใส่เครื่องหมาย double quotes เช่น `select * from "PostgreSQL"`

varchar(80): ระบุชนิดข้อมูลที่สามารถเก็บสตริงอักขระใดๆ ก็ได้ที่มีความยาวไม่เกิน 80 ตัว<br>
int: ชนิดข้อมูลจำนวนเต็มปกติ<br>
real: ใน PostgreSQL คือชนิดข้อมูลตัวเลขทศนิยมแบบความแม่นยำเดี่ยว

PostgreSQL รองรับชนิดข้อมูลมาตรฐานของ SQL ได้แก่ int, smallint, real, double precision, char(N), varchar(N), date, time, timestamp และ interval รวมถึงชนิดข้อมูลยูทิลิตี้ทั่วไปอื่นๆ และชนิดข้อมูลทางเรขาคณิตที่หลากหลาย

PostgreSQL สามารถกำหนดชนิดข้อมูลได้เอง (type) ได้ไม่จำกัด

ตัวอย่างที่สองจะจัดเก็บข้อมูลเมืองและตำแหน่งทางภูมิศาสตร์ที่เกี่ยวข้อง:

```
CREATE TABLE cities (
  name            varchar(80),
  location        point
);
```

ตัวอย่างการสร้าง type เช่น:

```
CREATE TYPE address AS (
  street text,
  city text
);
```

## Populating a Table With Rows

คำสั่ง `INSERT` ใช้สำหรับเพิ่มแถวลงในตาราง:

```
INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');
```

```
INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
```

รูปแบบไวยากรณ์ที่ใช้มาจนถึงตอนนี้ จำเป็นต้องจำลำดับของคอลัมน์ แต่มีรูปแบบไวยากรณ์ทางเลือก ที่ช่วยให้คุณระบุคอลัมน์ได้อย่างชัดเจน:

```
INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
  VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');
```

คุณสามารถเรียงลำดับคอลัมน์ใหม่ได้ตามต้องการ หรือแม้แต่ละเว้นบางคอลัมน์:

```
INSERT INTO weather (date, city, temp_hi, temp_lo)
  VALUES ('1994-11-29', 'Hayward', 54, 37);
```

นักพัฒนาหลายคนมองว่า การระบุคอลัมน์อย่างชัดเจน เป็นวิธีการเขียนโค้ดที่ดีกว่า การใช้ลำดับคอลัมน์

สามารถใช้คำสั่ง COPY เพื่อโหลดข้อมูลจำนวนมาก จากไฟล์ข้อความธรรมดาได้<br>
โดยปกติแล้ววิธีนี้จะเร็วกว่า เพราะคำสั่ง COPY ได้รับการปรับให้เหมาะสมกับการใช้งานประเภทนี้ แต่มีความยืดหยุ่นน้อยกว่าคำสั่ง INSERT

```
COPY weather FROM '/var/lib/postgresql/weather.txt'
WITH (FORMAT text, DELIMITER '|');
```

โดยไฟล์จะต้องมีอยู่ในเครื่องที่รันกระบวนการแบ็กเอนด์ (PostgreSQL) ไม่ใช่เครื่องไคลเอ็นต์ เนื่องจากกระบวนการแบ็กเอนด์ จะอ่านไฟล์โดยตรง

```
San Francisco|46|50|0.25|1994-11-27
San Francisco|43|57|0.0|1994-11-29
Hayward|37|54|\N|1994-11-29
```

## Querying a Table

ในการดึงข้อมูลจากตาราง จะต้องใช้คำสั่งสอบถามข้อมูลจากตารางนั้น. ใช้คำสั่ง SQL SELECT

```
SELECT * FROM weather;
```

\* [^1] ในที่นี้หมายถึง "ทุกคอลัมน์" ดังนั้นจะได้ผลลัพธ์เดียวกันกับ:

```
SELECT city, temp_lo, temp_hi, prcp, date FROM weather;
```

คุณสามารถเขียนนิพจน์ได้ ตัวอย่างเช่น:

```
SELECT city, (temp_hi+temp_lo)/2 AS temp_avg, date FROM weather;
```

คำสั่ง AS เพื่อเปลี่ยนชื่อคอลัมน์ (AS เป็นตัวเลือกเสริม)

สามารถ "กำหนดเงื่อนไข" การค้นหาได้โดยการเพิ่มส่วน WHERE เพื่อระบุว่าต้องการดึงข้อมูลแถวใดบ้าง. ส่วน WHERE ประกอบด้วยนิพจน์บูลีน (boolean) และจะส่งคืนเฉพาะแถว ที่นิพจน์บูลีนที่เป็นจริงเท่านั้น. สามารถใช้ตัวดำเนินการบูลีนทั่วไป (AND, OR และ NOT) ในการกำหนดเงื่อนไขได้

```
SELECT * FROM weather
    WHERE city = 'San Francisco' AND prcp > 0.0;
```

คุณสามารถขอให้การค้นหา แสดงผลลัพธ์โดยการเรียงลำดับได้:

```
SELECT * FROM weather
    ORDER BY city;
```

```
SELECT * FROM weather
    ORDER BY city, temp_lo;
```

สามารถขอให้ลบแถวที่ซ้ำกันออกจากผลลัพธ์ ได้ดังนี้:

```
SELECT DISTINCT city
    FROM weather;
```

ลำดับการแสดงผล ในแต่ละแถวอาจแตกต่างกันไป คุณสามารถทำให้ผลลัพธ์มีความสม่ำเสมอได้โดยใช้ DISTINCT ร่วมกับ ORDER BY [^2]

```
SELECT DISTINCT city
    FROM weather
    ORDER BY city;
```

### Footnotes

[^1]: แม้ว่าคำสั่ง SELECT \* จะมีประโยชน์สำหรับการค้นหาข้อมูลได้ทันที แต่โดยทั่วไปแล้วถือว่าเป็นรูปแบบการเขียนโค้ดที่ไม่ดีในโค้ดที่ใช้งานจริง เนื่องจากหากเพิ่มคอลัมน์ลงในตาราง ผลลัพธ์ก็จะเปลี่ยนแปลงไป

[^2]: ในระบบฐานข้อมูลบางระบบ รวมถึง PostgreSQL เวอร์ชันเก่า การใช้งาน DISTINCT จะเรียงลำดับแถวโดยอัตโนมัติ ดังนั้นจึงไม่จำเป็นต้องใช้ ORDER BY
