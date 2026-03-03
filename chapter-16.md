## Architectural Fundamentals

ในศัพท์ทางฐานข้อมูล PostgreSQL ใช้โมเดลแบบ Client/Server (ลูกข่าย/แม่ข่าย)

โดยเซสชัน (Session) ของ PostgreSQL จะประกอบด้วยกระบวนการ (โปรแกรม) ที่ทำงานร่วมกันดังต่อไปนี้: กระบวนการเซิร์ฟเวอร์ (Server Process) ซึ่งจัดการไฟล์ฐานข้อมูลรับการเชื่อมต่อจากแอปพลิเคชันไคลเอนต์ และดำเนินการจัดการฐานข้อมูลแทนไคลเอนต์ (โปรแกรมนี้เรียกว่า postgres) และแอปพลิเคชันไคลเอนต์ (Frontend) ของผู้ใช้ :

- Server Process (postgres): ทำหน้าที่หลักในการบริหารจัดการข้อมูลรับคำสั่งจาก client และประมวลผล.
- Client Application: โปรแกรมหน้าบ้านที่ผู้ใช้ใช้งาน เช่น เครื่องมือแบบข้อความ (Text-oriented tool) แอปพลิเคชันกราฟิก, Web Server หรือเครื่องมือบำรุงรักษาฐานข้อมูล

โดยทั่วไปแล้ว client / server นั้นสามารถอยู่บนโฮสต์ที่แตกต่างกันได้ ในกรณีนี้จะสื่อสารกันผ่านการเชื่อมต่อเครือข่าย TCP/IP

## Installation

```
  sudo apt install -y postgresql-common
  sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
  sudo apt install -y postgresql-18
```

```
  docker run -d --rm --name pg -p 5432:5432 -e POSTGRES_PASSWORD=123qwe postgres:18
```

## The PostgreSQL User Account

เช่นเดียวกับโปรแกรมเซิร์ฟเวอร์ (daemon) [^1] อื่นๆ ที่เปิดให้เข้าถึงจากภายนอก ควรรัน PostgreSQL ภายใต้บัญชีผู้ใช้ (user account) ที่แยกต่างหาก

บัญชีผู้ใช้นี้ควรเป็นเจ้าของเฉพาะข้อมูล ที่จัดการโดยเซิร์ฟเวอร์เท่านั้น และไม่ควรแชร์กับ daemons อื่นๆ (ตัวอย่างเช่น การใช้ผู้ใช้ nobody เป็นความคิดที่ไม่ดี)

ขอแนะนำว่าบัญชีผู้ใช้นี้ [^2] ไม่ควรเป็นเจ้าของไฟล์ปฏิบัติการของ PostgreSQL เพื่อให้แน่ใจว่ากระบวนการเซิร์ฟเวอร์ ที่ถูกบุกรุกจะไม่สามารถแก้ไขไฟล์ปฏิบัติการเหล่านั้นได้ เช่น :

```
  /usr/lib/postgresql/16/bin/postgres
  /usr/bin/psql
```

## Creating a Database Cluster

ก่อนอื่นจะทำอะไร ต้องเตรียมพื้นที่จัดเก็บฐานข้อมูลบนดิสก์ก่อน เราเรียกสิ่งนี้ว่า `database cluster` (มาตรฐาน SQL ใช้คำว่า `catalog cluster`) `database cluster` คือกลุ่มของ `databases` ที่ได้รับการจัดการโดย อินสแตนซ์เดียว ของเซิร์ฟเวอร์ฐานข้อมูลที่กำลังทำงานอยู่

หลังจากเริ่มต้นระบบแล้ว `database cluster` จะประกอบด้วยฐานข้อมูลชื่อ postgres ซึ่งมีจุดประสงค์ เพื่อใช้เป็นฐานข้อมูลเริ่มต้นสำหรับ utitlities, users และ third party applications

เซิร์ฟเวอร์ฐานข้อมูลตัวมันเอง ไม่จำเป็นต้องมีฐานข้อมูล postgres อยู่ แต่โปรแกรมยูทิลิตี้ภายนอก หลายโปรแกรมจะคิดว่ามันมีอยู่ เช่น `psql -U postgres` มันจะพยายาม connect เข้า database ที่ชื่อ เหมือน username

```
psql: error: FATAL: database "postgres" does not exist
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

ในแง่ของระบบไฟล์ database cluster คือไดเร็กทอรีเดียวที่ใช้เก็บข้อมูลทั้งหมด เราเรียกสิ่งนี้ว่า `data directory` หรือ `data area` คุณสามารถเลือกที่จัดเก็บข้อมูลได้เองทั้งหมด

ไม่มีค่าเริ่มต้นตายตัว แต่ตำแหน่งที่นิยมใช้ ได้แก่ `/usr/local/pgsql/data` หรือ `/var/lib/pgsql/data` [^3]

หากคุณกำลังใช้งาน PostgreSQL เวอร์ชันที่ถูกแพ็คเกจมาสำเร็จรูป (pre-packaged) มันอาจจะมีข้อกำหนด/แนวทางปฏิบัติ (convention) เฉพาะเจาะจงว่าควรวางไดเรกทอรีข้อมูลไว้ที่ใด และอาจมีสคริปต์สำหรับสร้างไดเรกทอรีข้อมูลเตรียมไว้ให้ด้วย

ในการเริ่มต้น `database cluster` ด้วยตนเอง ให้ใช้คำสั่ง `initdb` และระบุตำแหน่งระบบไฟล์ที่ต้องการของ `database cluster` โดยใช้ตัวเลือก -D ตัวอย่างเช่น :

```
initdb -D /usr/local/pgsql/data
```

หรือเพิ่ม environment variable ใน ~/.profile ก่อน

```
initdb
```

```
export PGDATA=/usr/local/pgsql/data
```

หลังจากนั้น source ~/.profile

หากปรากฏ `initdb: command not found` ให้ใช้คำสั่ง:

```
sudo ln -s /usr/lib/postgresql/18/bin/initdb /usr/bin/initdb
```

initdb จะพยายามสร้างไดเร็กทอรีที่คุณระบุหากยังไม่มีอยู่ แน่นอนว่าขั้นตอนนี้จะล้มเหลว initdb ไม่มีสิทธิ์ในการเขียนใน /usr/local directory แนะนำให้ผู้ใช้ PostgreSQL เป็นเจ้าของไม่เพียงแค่ data directory เท่านั้น แต่รวมถึง pgsql directory ด้วย เพื่อไม่ให้เกิดปัญหานี้

คุณจะต้องสร้างมันขึ้นมาก่อน โดยใช้สิทธิ์ root หาก /usr/local ไม่สามารถเขียนได้ ดังนั้นกระบวนการจะมีลักษณะดังนี้:

```
root# mkdir /usr/local/pgsql
root# chown postgres /usr/local/pgsql
root# su postgres
postgres$ initdb -D /usr/local/pgsql/data
```

เนื่องจาก data directory ประกอบด้วยข้อมูลทั้งหมด ที่จัดเก็บอยู่ในฐานข้อมูล จึงจำเป็นอย่างยิ่งที่จะต้องรักษาความปลอดภัย จากการเข้าถึงโดยไม่ได้รับอนุญาต

ดังนั้น initdb จึงเพิกถอนสิทธิ์การเข้าถึง จากทุกคน ยกเว้นผู้ใช้ PostgreSQL และอาจรวมถึงกลุ่มด้วย

การเข้าถึงแบบกลุ่ม เมื่อเปิดใช้งาน จะต้องเป็น `read-only`
เพื่อที่จะสามารถสำรอง cluster data หรือดำเนินการอื่นๆ ที่ต้องการเพียงสิทธิ์ในการอ่านเท่านั้นได้

### Footnotes

[^1]: daemon คือโปรแกรมที่รันอยู่เบื้องหลังตลอดเวลา เช่น

    - Web server (เช่น Nginx, Apache)
    - Database server (เช่น PostgreSQL)
    - SSH server

[^2]: โดยปกติแล้ว เวอร์ชันสำเร็จรูปของ PostgreSQL จะสร้างบัญชีผู้ใช้ที่เหมาะสมโดยอัตโนมัติ ระหว่างการติดตั้งแพ็กเกจ

[^3]:
    แต่หากติดตั้งผ่าน docker `data directory` จะถูกสร้างอัตโนมัติที่
    `/var/lib/postgresql/18/docker`
