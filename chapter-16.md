## Installation from Binaries

website at https://www.postgresql.org/download/

## The PostgreSQL User Account

- เช่นเดียวกับโปรแกรมเซิร์ฟเวอร์ (daemon) [^1] อื่นๆ ที่เปิดให้เข้าถึงจากภายนอก ควรรัน PostgreSQL ภายใต้บัญชีผู้ใช้ (user account) ที่แยกต่างหาก
- บัญชีผู้ใช้นี้ควรเป็นเจ้าของเฉพาะข้อมูล ที่จัดการโดยเซิร์ฟเวอร์เท่านั้น และไม่ควรแชร์กับ daemons อื่นๆ (ตัวอย่างเช่น การใช้ผู้ใช้ nobody เป็นความคิดที่ไม่ดี)
- ขอแนะนำว่าบัญชีผู้ใช้นี้ [^2] ไม่ควรเป็นเจ้าของไฟล์ปฏิบัติการของ PostgreSQL เพื่อให้แน่ใจว่ากระบวนการเซิร์ฟเวอร์ ที่ถูกบุกรุกจะไม่สามารถแก้ไขไฟล์ปฏิบัติการเหล่านั้นได้ เช่น
  - ```
    /usr/lib/postgresql/16/bin/postgres
    /usr/bin/psql
    ```

## Creating a Database Cluster

ก่อนอื่นจะทำอะไร ต้องเตรียมพื้นที่จัดเก็บฐานข้อมูลบนดิสก์ก่อน เราเรียกสิ่งนี้ว่า `database cluster` (มาตรฐาน SQL ใช้คำว่า `catalog cluster`) `database cluster` คือกลุ่มของ `databases` ที่ได้รับการจัดการโดย อินสแตนซ์เดียว ของเซิร์ฟเวอร์ฐานข้อมูลที่กำลังทำงานอยู่

หลังจากเริ่มต้นระบบแล้ว `database cluster` จะประกอบด้วยฐานข้อมูลชื่อ postgres ซึ่งมีจุดประสงค์ เพื่อใช้เป็นฐานข้อมูลเริ่มต้นสำหรับ utitlities, users และ third party applications

เซิร์ฟเวอร์ฐานข้อมูลตัวมันเอง ไม่จำเป็นต้องมีฐานข้อมูล postgres อยู่ แต่โปรแกรมยูทิลิตี้ภายนอก หลายโปรแกรมจะคิดว่ามันมีอยู่ เช่น `psql -U postgres` มันจะพยายาม connect เข้า database ที่ชื่อ เหมือน username

```
psql: error: FATAL:  database "postgres" does not exist
```

ระหว่างการเริ่มต้นระบบ จะมีการสร้างฐานข้อมูลเพิ่มอีก 2 databases ภายในแต่ละคลัสเตอร์ โดยตั้งชื่อว่า template1 และ template0 ฐานข้อมูลเหล่านี้ จะใช้เป็นแม่แบบสำหรับฐานข้อมูล ที่จะสร้างขึ้นในภายหลัง ไม่ควรนำไปใช้งานจริง

ทำไมถึงมี `database` ชื่อ `postgres` มาให้?<br>
ตอน init cluster (initdb) จะสร้าง 3 ตัวหลัก:
| Database | หน้าที่ |
| --- | --- |
| template0 | ใช้ clone DB แบบ clean |
| template1 | ใช้เป็น template ปกติ |
| postgres | ใช้เป็น default DB สำหรับ admin |

postgres มีไว้เป็น safe default สำหรับ:

- login เข้าไปจัดการระบบ
- run admin commands
- ไม่ไปยุ่งกับ production database

ในแง่ของระบบไฟล์ database cluster คือไดเร็กทอรีเดียวที่ใช้เก็บข้อมูลทั้งหมด เราเรียกสิ่งนี้ว่า `data directory` หรือ `data area`

### Footnotes

[^1]: daemon คือโปรแกรมที่รันอยู่เบื้องหลังตลอดเวลา เช่น

    - Web server (เช่น Nginx, Apache)
    - Database server (เช่น PostgreSQL)
    - SSH server

[^2]: โดยปกติแล้ว เวอร์ชันสำเร็จรูปของ PostgreSQL จะสร้างบัญชีผู้ใช้ที่เหมาะสมโดยอัตโนมัติ ระหว่างการติดตั้งแพ็กเกจ
