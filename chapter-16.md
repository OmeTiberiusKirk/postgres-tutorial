## wsl

### Installing a Linux distribution

wsl --install ubuntu-24.04

### export & imoprt distro

```
wsl --terminate ubuntu-24.04
wsl --export ubuntu-24.04 $USERPROFILE/Downloads/ubuntu.tar
wsl --import ubuntu-24.04 $USERPROFILE/AppData/Local/Packages/Ubuntu $USERPROFILE/Downloads/ubuntu.tar
```

### ปิด dir background โดยการแก้ไข

```
//  ~/.bashrc
LS_COLORS=$LS_COLORS:'ow=1;34:'
```

จากนั้น source ~/.bashrc

### Vim for all users.

`/etc/vim/vimrc.local`

## Architectural Fundamentals

ในศัพท์ทางฐานข้อมูล PostgreSQL ใช้โมเดลแบบ Client/Server (ลูกข่าย/แม่ข่าย)

โดยเซสชัน (Session) ของ PostgreSQL จะประกอบด้วยกระบวนการ (โปรแกรม) ที่ทำงานร่วมกันดังต่อไปนี้: กระบวนการเซิร์ฟเวอร์ (Server Process) ซึ่งจัดการไฟล์ฐานข้อมูลรับการเชื่อมต่อจากแอปพลิเคชันไคลเอนต์ และดำเนินการจัดการฐานข้อมูลแทนไคลเอนต์ (โปรแกรมนี้เรียกว่า postgres) และแอปพลิเคชันไคลเอนต์ (Frontend) ของผู้ใช้ :

- Server Process (postgres): ทำหน้าที่หลักในการบริหารจัดการข้อมูลรับคำสั่งจาก client และประมวลผล.
- Client Application: โปรแกรมหน้าบ้านที่ผู้ใช้ใช้งาน เช่น เครื่องมือแบบข้อความ (Text-oriented tool) แอปพลิเคชันกราฟิก, Web Server หรือเครื่องมือบำรุงรักษาฐานข้อมูล

โดยทั่วไปแล้ว client / server นั้นสามารถอยู่บนโฮสต์ที่แตกต่างกันได้ ในกรณีนี้จะสื่อสารกันผ่านการเชื่อมต่อเครือข่าย TCP/IP

## Installing the software packages

```
sudo apt update &&
sudo apt install -y bzip2 build-essential pkg-config libicu-dev \
bison flex libreadline-dev zlib1g-dev
```

## Getting the Source

ดาวน์โหลดไฟล์ได้ที่ https://www.postgresql.org/ftp/source/ หาเวอร์ชั่นที่ต้องการ postgresql-{version}.tar.gz หรือ postgresql-{version}.tar.bz2 แล้วแตกไฟล์:

```
tar -xvf postgresql-{version}.tar.gz
```

## Building and Installation

```
./configure
make
sudo su
make install
adduser postgres
mkdir -p /usr/local/pgsql/data
chown postgres /usr/local/pgsql/data
su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start
/usr/local/pgsql/bin/createdb test
/usr/local/pgsql/bin/psql test
```

## Adding a path for Command Line Utilities

```
export PATH=$PATH:/usr/local/pgsql/bin
```

## The PostgreSQL User Account

เช่นเดียวกับโปรแกรมเซิร์ฟเวอร์ (daemon) [^1] อื่นๆ ที่เปิดให้เข้าถึงจากภายนอก ควรรัน PostgreSQL ภายใต้บัญชีผู้ใช้ (user account) ที่แยกต่างหาก

บัญชีผู้ใช้นี้ควรเป็นเจ้าของเฉพาะข้อมูล ที่จัดการโดยเซิร์ฟเวอร์เท่านั้น และไม่ควรแชร์กับ daemon อื่นๆ

(ตัวอย่างเช่น การใช้ผู้ใช้ nobody เป็นความคิดที่ไม่ดี) ขอแนะนำว่าบัญชีผู้ใช้นี้ ไม่ควรเป็นเจ้าของไฟล์ปฏิบัติการของ PostgreSQL เพื่อให้แน่ใจว่ากระบวนการเซิร์ฟเวอร์ ที่ถูกบุกรุกจะไม่สามารถแก้ไขไฟล์ปฏิบัติการเหล่านั้นได้ เช่น :

```
  /usr/local/pgsql/bin/postgres
  /usr/local/pgsql/bin/psql
```

## Creating a Database Cluster

ก่อนอื่นจะทำอะไร ต้องเตรียมพื้นที่จัดเก็บฐานข้อมูลบนดิสก์ก่อน เราเรียกสิ่งนี้ว่า `database cluster` (มาตรฐาน SQL ใช้คำว่า `catalog cluster`) `database cluster` คือกลุ่มของ `databases` ที่ได้รับการจัดการโดย อินสแตนซ์เดียว ของเซิร์ฟเวอร์ฐานข้อมูลที่กำลังทำงานอยู่

หลังจากเริ่มต้นระบบแล้ว `database cluster` จะประกอบด้วยฐานข้อมูลชื่อ postgres ซึ่งมีจุดประสงค์ เพื่อใช้เป็นฐานข้อมูลเริ่มต้นสำหรับ utitlities, users และ third party applications

postgres มีไว้เป็น safe default สำหรับ:

- login เข้าไปจัดการระบบ
- run admin commands
- ไม่ไปยุ่งกับ production database

ในแง่ของระบบไฟล์ database cluster คือ `directory` เดียวที่ใช้เก็บข้อมูลทั้งหมด เราเรียกสิ่งนี้ว่า `data directory` หรือ `data area` คุณสามารถเลือกที่จัดเก็บข้อมูลได้เองทั้งหมด

ไม่มีค่าเริ่มต้นตายตัว แต่ตำแหน่งที่นิยมใช้ ได้แก่ `/usr/local/pgsql/data` หรือ `/var/lib/pgsql/data`

ในการเริ่มต้น `database cluster` ด้วยตนเอง ให้ใช้คำสั่ง `initdb` และระบุตำแหน่งระบบไฟล์ที่ต้องการของ `database cluster` โดยใช้ตัวเลือก -D ตัวอย่างเช่น :

```
initdb -D /usr/local/pgsql/data
```

<style>
.tip-box {
  border: 1px solid #00c911;;
  padding: 15px;
  border-radius: 5px;
  margin: 0 auto 15px;
  max-width: 600px;
}
</style>
<div class="tip-box">
  <p style="text-align:center;">Tip</p>
  # หรือเพิ่ม environment variable ใน ~/.profile<br>
  export PGDATA=/usr/local/pgsql/data<br>
  # หลังจากนั้น source ~/.profile
</div>

`initdb` จะพยายามสร้าง `directory` ที่คุณระบุหากยังไม่มีอยู่ แน่นอนว่าขั้นตอนนี้จะล้มเหลว initdb ไม่มีสิทธิ์ในการเขียนใน `/usr/local` directory แนะนำให้ผู้ใช้ `postgres` เป็นเจ้าของไม่เพียงแค่ data directory เท่านั้น แต่รวมถึง pgsql directory ด้วย เพื่อไม่ให้เกิดปัญหานี้

คุณจะต้องสร้างมันขึ้นมาก่อน โดยใช้สิทธิ์ root หาก /usr/local ไม่สามารถเขียนได้ ดังนั้นกระบวนการจะมีลักษณะดังนี้:

```
sudo mkdir /usr/local/pgsql
sudo chown postgres /usr/local/pgsql
initdb -D /usr/local/pgsql/data
```

เนื่องจาก data directory ประกอบด้วยข้อมูลทั้งหมด ที่จัดเก็บอยู่ในฐานข้อมูล จึงจำเป็นอย่างยิ่งที่จะต้องรักษาความปลอดภัย จากการเข้าถึงโดยไม่ได้รับอนุญาต ดังนั้น initdb จึงเพิกถอนสิทธิ์การเข้าถึง จากทุกคน ยกเว้นผู้ใช้ `postgres` และอาจรวมถึงกลุ่มด้วย การเข้าถึงแบบกลุ่ม เมื่อเปิดใช้งาน จะต้องเป็น `read-only` ซึ่งจะอนุญาตให้ผู้ใช้ที่ไม่มีสิทธิ์ ซึ่งอยู่ในกลุ่มเดียวกันกับเจ้าของคลัสเตอร์ สามารถสำรองข้อมูลคลัสเตอร์ หรือดำเนินการอื่นๆ ที่ต้องการเพียงสิทธิ์ในการอ่านเท่านั้นได้

การให้ หรือไม่ให้เข้าถึงแบบกลุ่มบนคลัสเตอร์ จำเป็นต้องปิดคลัสเตอร์ แล้วค่อยตั้งค่าโหมดที่เหมาะสมสำหรับ `directory` และไฟล์ทั้งหมดก่อน ที่จะเริ่มต้น PostgreSQL ใหม่
มิเช่นนั้น อาจมีโหมดต่างๆ ปะปนกันอยู่ใน `data directory`

- สำหรับคลัสเตอร์ที่อนุญาตให้เข้าถึงได้เฉพาะเจ้าของ โหมดที่เหมาะสมคือ 0700 สำหรับ `directory` และ 0600 สำหรับไฟล์
- สำหรับคลัสเตอร์ที่อนุญาตให้กลุ่มอ่านได้ด้วย โหมดที่เหมาะสมคือ 0750 สำหรับ `directory` และ 0640 สำหรับไฟล์

```
# ปิด cluster
pg_ctl -D /usr/local/pgsql/data stop -l logfile

# สำหรับ directories
find $PGDATA -type d -exec chmod 700 {} +

# สำหรับ files
find $PGDATA -type f -exec chmod 600 {} +

# เปิด cluster
pg_ctl -D /usr/local/pgsql/data start -l logfile
```

อย่างไรก็ตาม แม้ว่าเนื้อหาใน `directory` จะปลอดภัย แต่การตั้งค่าการตรวจสอบสิทธิ์ไคลเอ็นต์เริ่มต้น อนุญาตให้ local user ใดก็ตาม สามารถเชื่อมต่อกับฐานข้อมูล แม้จะเป็นผู้ใช้ระดับสูงสุด ของฐานข้อมูลก็ตาม

หากคุณไม่ไว้วางใจผู้ใช้ภายในเครื่องอื่น เราขอแนะนำให้คุณใช้ตัวเลือก -W, --pwprompt หรือ --pwfile ตอน initdb เพื่อกำหนดรหัสผ่าน ให้กับผู้ใช้ระดับสูงสุดของฐานข้อมูล

นอกจากนี้ ให้ระบุ -A scram-sha-256 เพื่อไม่ให้ใช้โหมด trust ในการตรวจสอบสิทธิ์ หรือแก้ไขไฟล์ pg_hba.conf ที่สร้างขึ้นหลังจากเรียกใช้ initdb ก็ได้

คำสั่ง initdb จะกำหนดค่า locale เริ่มต้นให้ `database cluster` ด้วย โดยปกติแล้ว คำสั่งนี้จะใช้การตั้งค่า locale ในสภาพแวดล้อม และนำไปใช้กับฐานข้อมูลที่เริ่มต้นใช้งาน

```
# 1. ติดตั้งภาษาไทยลงใน OS
sudo locale-gen th_TH.UTF-8

# 2. อัปเดตการตั้งค่าภาษา
sudo update-locale
```

ค่าเริ่มต้นลำดับการจัดเรียง ที่ใช้ภายใน `database cluster` นั้น ถูกกำหนดโดย initdb และถึงแม้คุณจะสามารถสร้างฐานข้อมูลใหม่ โดยใช้ลำดับการจัดเรียงที่แตกต่างกันได้ [^2] แต่ลำดับที่ใช้ในฐานข้อมูล template ที่ initdb สร้างขึ้นนั้นไม่สามารถเปลี่ยนแปลงได้ นอกจากจะลบและสร้างใหม่ การใช้ locale อื่นที่ไม่ใช่ C หรือ POSIX [^3] ยังส่งผลกระทบ ต่อประสิทธิภาพการทำงานเช่นกัน ดังนั้น การเลือกภาษาท้องถิ่น ให้ถูกต้องตั้งแต่ครั้งแรกจึงเป็นสิ่งสำคัญ

คำสั่ง initdb ยังตั้งค่าการเข้ารหัสชุดอักขระเริ่มต้น สำหรับคลัสเตอร์ฐานข้อมูลด้วย โดยปกติแล้วควรเลือกให้ตรงกับ การตั้งค่า locale

locale ที่ไม่ใช่ C และไม่ใช่ POSIX จะอาศัยไลบรารีการเรียงลำดับ `ของระบบปฏิบัติการ` ในการจัดเรียงชุดอักขระ ซึ่งควบคุมลำดับของคีย์ ที่จัดเก็บไว้ในดัชนี สิ่งนี้ควบคุมลำดับของคีย์ที่จัดเก็บไว้ในดัชนี ด้วยเหตุนี้ คลัสเตอร์จึงไม่สามารถเปลี่ยนไปใช้ เวอร์ชั่นไลบรารีการเรียงลำดับที่ต่างกันได้ ไม่ว่าจะด้วยวิธีการกู้คืนสแนปช็อต, การจำลองแบบสตรีมมิ่งไบนารี, OS ที่แตกต่างกัน หรือการอัปเกรด OS

## Use of Secondary File Systems (External Storage)

เหตุผลที่ควรเข้าไปสร้าง `sub directory` แทนที่จะวางข้อมูลไว้ที่จุด `mount point` โดยตรง

### ปัญหาเรื่องสิทธิ์การเข้าถึง (Permissions)

โดยปกติแล้ว Mount Point (เช่น /data หรือ /mnt/db) มักจะมี root เป็นเจ้าของสิทธิ์ ซึ่งการเปลี่ยนเจ้าของ (Ownership) ที่ตัว Mount Point เลยอาจสร้างความยุ่งยากเมื่อมีการอัปเกรดระบบ หรือใช้ Tool อย่าง pg_upgrade ที่ต้องการสิทธิ์ในการเขียน/อ่านที่ชัดเจนและจำกัดเฉพาะ User postgres

โครงสร้างที่แนะนำ:

- /mnt/db (Mount Point: เจ้าของคือ root)
  - /pgsql (Sub-directory: เจ้าของคือ postgres)
    - /data (Actual Data Dir: เจ้าของคือ postgres)

### การแยกแยะความล้มเหลว (Clean Failures)

ถ้าคุณสั่งให้ติดตั้ง PostgreSQL ไปที่ /mnt/db โดยตรง แต่เกิดเหตุการณ์ที่ Disk หลุด (Unmounted) :

- ถ้าใช้ Mount Point ตรงๆ Postgres อาจจะเผลอไปเขียนข้อมูลลงบน Partition หลัก (/) ของเครื่องแทน เพราะโฟลเดอร์ /mnt/db ยังคงมีอยู่ (ในฐานะ empty directory บน root) ทำให้ Disk ของระบบเต็มและเครื่องค้างได้
- ถ้าใช้ Directory ย่อย เมื่อ Disk หลุด โฟลเดอร์ย่อยจะหายไปด้วย Postgres จะหาโฟลเดอร์ข้อมูลไม่เจอและ หยุดทำงาน (Fail) ทันที ซึ่งปลอดภัยกว่าการเขียนข้อมูลผิดที่

## Starting the Database Server

วิธีที่ง่ายที่สุดในการเริ่มเซิร์ฟเวอร์ด้วยตนเอง คือการเรียกใช้ `postgres` โดยตรง โดยระบุตำแหน่งของ `data directory` ด้วยตัวเลือก -D ตัวอย่างเช่น :

```
postgres -D /usr/local/pgsql/data
```

ซึ่งจะปล่อยให้เซิร์ฟเวอร์ทำงานอยู่เบื้องหน้า ต้องทำเช่นนี้ในขณะที่ล็อกอินเข้าสู่บัญชีผู้ใช้ `postgres` แล้ว หากไม่มีตัวเลือก -D เซิร์ฟเวอร์จะพยายามใช้ `data directory` ที่กำหนดโดยตัวแปรสภาพแวดล้อม `PGDATA` หากไม่ได้ระบุตัวแปรนั้นด้วย การทำงานจะล้มเหลว

โดยปกติแล้วการเริ่มต้น PostgreSQL ให้ทำงานเบื้องหลัง (Background Process) จะดีกว่า สำหรับการทำเช่นนั้น ให้ใช้ไวยากรณ์เชลล์ Unix ปกติ:

```
postgres -D /usr/local/pgsql/data > logfile 2>&1 &
```

สิ่งสำคัญคือ ต้องจัดเก็บเอาต์พุต stdout และ stderr ของเซิร์ฟเวอร์ไว้ในที่ใดที่หนึ่ง ดังตัวอย่างข้างบน ซึ่งจะช่วยในการตรวจสอบ และวินิจฉัยปัญหา

ไวยากรณ์ของ Shell นี้อาจทำให้ยุ่งยาก และจุกจิกกับเครื่องหมายต่างๆ ดังนั้นจึงมีโปรแกรมตัวช่วย `pg_ctl` เพื่อทำให้บางงานง่ายขึ้น ตัวอย่างเช่น:

```
pg_ctl -D /usr/local/pgsql/data start -l logfile
```

คำสั่งนี้เซิร์ฟเวอร์จะเริ่มทำงานอยู่เบื้องหลัง (Background Process) และบันทึกผลลัพธ์ลงในไฟล์ Log ที่ระบุชื่อไว้ ตัวเลือก -D มีความหมายเช่นเดียวกับที่ใช้กับ postgres นอกจากนี้ pg_ctl ยังสามารถหยุดเซิร์ฟเวอร์ได้ด้วย

โดยปกติแล้ว ควรเริ่มต้น `database server` เมื่อคอมพิวเตอร์บูตเครื่อง สคริปต์การเริ่มต้นอัตโนมัติ จะขึ้นอยู่กับระบบปฏิบัติการ มีสคริปต์ตัวอย่างบางส่วน ที่แจกจ่ายมาพร้อมกับ PostgreSQL ใน directory (ที่ดาวน์โหลด) contrib/start-scripts การติดตั้งสคริปต์ใดสคริปต์หนึ่ง จะต้องใช้สิทธิ์ผู้ดูแลระบบ (root privileges)

### Footnotes

[^1]: daemon คือโปรแกรมที่รันอยู่เบื้องหลังตลอดเวลา เช่น Web server (เช่น Nginx, Apache), Database server (เช่น PostgreSQL) และ SSH server

[^2]: แม้ว่า initdb หากกำหนดค่าเริ่มต้นของ Cluster เป็น en_US ไปแล้ว แต่ PostgreSQL ออกแบบมาให้เราสามารถสร้าง Database ใหม่ที่มีการตั้งค่า Locale ต่างจากค่าเริ่มต้นได้ (เรียกว่าการ Overwrite ค่า Default) แต่เวลาคุณสั่งรัน Tool บางอย่างผ่าน Command Line (เช่น reindexdb หรือ vacuumdb) ถ้าไม่ได้ระบุ Database ให้ชัดเจน มันอาจจะอ้างอิงค่าจาก User Environment แทน

[^3]: C หรือ POSIX เรียงตาม Binary ไม่สนภาษา ปลอดภัยที่สุดในการย้ายเครื่อง แต่อาจเรียงภาษาไทยไม่ค่อยดี
