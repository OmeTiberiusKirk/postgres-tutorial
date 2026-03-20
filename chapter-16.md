## wsl

### Installing the Ubuntu distribution.

```
# Displays a list of available distributions for install with 'wsl.exe --install'.
wsl --list -o

# Install a Windows Subsystem for Linux distribution.
wsl --install ubuntu-24.04
```

### export & imoprt distro

```
# Terminates the specified distribution.
wsl --terminate ubuntu-24.04

# Exports the distribution to a tar file.
wsl --export ubuntu-24.04 $USERPROFILE/Downloads/ubuntu.tar

# Imports the specified tar file as a new distribution.
wsl --import ubuntu-24.04 $USERPROFILE/AppData/Local/Packages/Ubuntu $USERPROFILE/Downloads/ubuntu.tar
```

## Architectural Fundamentals

PostgreSQL จะใช้โมเดลแบบ Client/Server ซึ่งประกอบด้วย 2 ส่วนหลักที่ทำงานประสานกัน ดังนี้ครับ:

- ฝั่งเซิร์ฟเวอร์ (Server Process) คือโปรแกรมที่ทำหน้าที่เป็น "ตัวจัดการหลัก" มีชื่อเรียกเฉพาะว่า postgres หน้าที่ของมันคือ
  - จัดการไฟล์ข้อมูลทั้งหมดของฐานข้อมูล
  - รอรับการเชื่อมต่อ (Connections) จากแอปพลิเคชันฝั่ง Client
  - ทำงานต่างๆ ตามที่ Client สั่ง (เช่น การเขียน การอ่าน หรือการแก้ไขข้อมูล)

- ฝั่งไคลเอนต์ (Client Application) คือแอปพลิเคชันหรือโปรแกรมส่วนหน้า (Frontend) ที่ผู้ใช้ใช้งานเพื่อต้องการเข้าถึงข้อมูล ซึ่งมีความหลากหลายมาก เช่น:
  - เครื่องมือแบบข้อความ (Text-oriented): เช่น psql
  - แอปพลิเคชันแบบกราฟิก (GUI): เช่น pgAdmin
  - เว็บเซิร์ฟเวอร์: ที่เรียกใช้ฐานข้อมูลเพื่อนำข้อมูลไปแสดงบนหน้าเว็บ
  - เครื่องมือเฉพาะทาง: สำหรับการดูแลรักษาฐานข้อมูล

โดยทั่วไปแล้ว client / server นั้นสามารถอยู่บนโฮสต์ที่แตกต่างกันได้ ในกรณีนี้จะสื่อสารกันผ่านการเชื่อมต่อเครือข่าย TCP/IP

## Installing the software packages

```
sudo apt update && \
sudo apt install -y bzip2 build-essential pkg-config libicu-dev \
bison flex libreadline-dev zlib1g-dev libsystemd-dev
```

## Getting the Source

ดาวน์โหลดไฟล์ได้ที่ https://www.postgresql.org/ftp/source/ หาเวอร์ชั่นที่ต้องการ postgresql-{version}.tar.gz หรือ postgresql-{version}.tar.bz2 แล้วแตกไฟล์:

```
cp /mnt/c/Users/{user}/Downloads/postgresql-{version}.tar.bz2 ./
tar -xvf postgresql-{version}.tar.gz
```

## Building and Installation

```
# กำหนดค่า
./configure --with-systemd
# Build
make
# Installing the Files
sudo make install
```

## The PostgreSQL User Account

เช่นเดียวกับ Server ทั่วไป ที่เปิดให้โลกภายนอกเข้าถึงได้ มีคำแนะนำที่สำคัญมากดังนี้:

- ต้องใช้ Account แยกต่างหาก: ควรตั้ง User ขึ้นมาใหม่ (ปกติคือ postgres) เพื่อรัน PostgreSQL โดยเฉพาะ
- ห้ามแชร์ User ร่วมกับบริการอื่น: อย่าใช้ User เดียวกันไปรันอย่างอื่น (เช่น ห้ามใช้ nobody เพราะ nobody มักจะถูกใช้โดยบริการจิปาถะหลายตัว ถ้าตัวหนึ่งโดนเจาะ ตัวอื่นจะพลอยซวยไปด้วย)
- สิทธิ์เหนือข้อมูลเท่านั้น: User นี้ควรมีสิทธิ์ "เป็นเจ้าของ" (Owner) เฉพาะ ไฟล์ข้อมูล (Data Files) ที่ PostgreSQL จัดการเท่านั้น

เพื่อให้แน่ใจว่ากระบวนการเซิร์ฟเวอร์ ที่ถูกบุกรุกจะไม่สามารถแก้ไขไฟล์ปฏิบัติการเหล่านั้นได้ เช่น `/usr/local/pgsql/bin/postgres`, `/usr/local/pgsql/bin/psql`

```
sudo adduser postgres
```

## Adding a path for Command Line Utilities

```
su - postgres -c "echo 'export PATH=\$PATH:/usr/local/pgsql/bin' >> ~/.profile && source ~/.profile"
```

## Creating a Database Cluster

ก่อนอื่นต้องเตรียมพื้นที่ จัดเก็บฐานข้อมูลบนดิสก์ก่อน เราเรียกสิ่งนี้ว่า `database cluster` (มาตรฐาน SQL ใช้คำว่า `catalog cluster`) `database cluster` คือกลุ่มของ `databases` ที่ได้รับการจัดการโดย อินสแตนซ์เดียว ของเซิร์ฟเวอร์ฐานข้อมูลที่กำลังทำงานอยู่

หลังจากเริ่มต้นระบบแล้ว `database cluster` จะประกอบด้วยฐานข้อมูลชื่อ postgres ซึ่งมีจุดประสงค์ เพื่อใช้เป็นฐานข้อมูลเริ่มต้นสำหรับ utitlities, users และ third party applications

postgres มีไว้เป็น safe default สำหรับ:

- login เข้าไปจัดการระบบ
- run admin commands
- ไม่ไปยุ่งกับ production database

ในแง่ของระบบไฟล์ database cluster คือ `directory` เดียวที่ใช้เก็บข้อมูลทั้งหมด เราเรียกสิ่งนี้ว่า `data directory` หรือ `data area` คุณสามารถเลือกที่จัดเก็บข้อมูลได้เองทั้งหมด

ไม่มีค่าเริ่มต้นตายตัว แต่ตำแหน่งที่นิยมใช้ ได้แก่ `/usr/local/pgsql/data` หรือ `/var/lib/pgsql/data`

ในการเริ่มต้น `database cluster` ด้วยตนเอง ให้ใช้คำสั่ง `initdb` และระบุตำแหน่งระบบไฟล์ที่ต้องการของ `database cluster` โดยใช้ตัวเลือก -D ตัวอย่างเช่น :

```
su - postgres -c "initdb -D /usr/local/pgsql/data"

# หากไม่ต้องการใส่ '-D /usr/local/pgsql/data' ทุกครั้ง ในการใช้ utilities
su - postgres -c "echo 'export PGDATA=/usr/local/pgsql/data' >> ~/.profile && source ~/.profile"
```

`initdb` จะพยายามสร้าง `directory` ที่คุณระบุหากยังไม่มีอยู่ แน่นอนว่าขั้นตอนนี้จะล้มเหลว initdb ไม่มีสิทธิ์ในการเขียนใน `/usr/local` directory แนะนำให้ผู้ใช้ `postgres` เป็นเจ้าของ data directory เท่านั้น

คุณจะต้องสร้างมันขึ้นมาก่อน โดยใช้สิทธิ์ root หาก /usr/local ไม่สามารถเขียนได้ ดังนั้นกระบวนการจะมีลักษณะดังนี้:

```
sudo mkdir -p /usr/local/pgsql/data
sudo chown postgres /usr/local/pgsql/data
su - postgres -c "initdb"
su - postgres -c "pg_ctl -l logfile start"
```

เนื่องจาก `data directory` ประกอบด้วยข้อมูลทั้งหมด ที่จัดเก็บอยู่ในฐานข้อมูล จึงจำเป็นอย่างยิ่งที่จะต้องรักษาความปลอดภัย จากการเข้าถึงโดยไม่ได้รับอนุญาต<br>
ดังนั้น initdb จึงเพิกถอนสิทธิ์การเข้าถึง (`data directory`) จากทุกคน ยกเว้นผู้ใช้ `postgres` และอาจรวมถึงกลุ่มด้วย การเข้าถึงแบบกลุ่ม เมื่อเปิดใช้งานจะต้องเป็นแบบ `read-only` ซึ่งจะอนุญาตให้ผู้ใช้ที่ไม่มีสิทธิ์ ซึ่งอยู่ในกลุ่มเดียวกันกับเจ้าของคลัสเตอร์ สามารถสำรองข้อมูลคลัสเตอร์ หรือดำเนินการอื่นๆ ที่ต้องการเพียงสิทธิ์ในการอ่านเท่านั้นได้

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

อย่างไรก็ตาม แม้ว่าเนื้อหาใน `directory` จะปลอดภัย แต่การตั้งค่าการตรวจสอบสิทธิ์ไคลเอ็นต์เริ่มต้น อนุญาตให้ local user ใดก็ตาม สามารถเชื่อมต่อกับฐานข้อมูล แม้จะเป็นผู้ใช้ระดับสูงสุด ของฐานข้อมูลก็ตาม<br>
หากคุณไม่ไว้วางใจผู้ใช้ภายในเครื่องอื่น เราขอแนะนำให้คุณใช้ตัวเลือก -W, --pwprompt หรือ --pwfile ตอน initdb เพื่อกำหนดรหัสผ่าน ให้กับผู้ใช้ระดับสูงสุดของฐานข้อมูล

```
# psql
\password postgres
# หรือ
ALTER USER postgres WITH PASSWORD '123qwe';
```

นอกจากนี้ ให้ระบุ -A scram-sha-256 เพื่อไม่ให้ใช้โหมด trust ในการตรวจสอบสิทธิ์ หรือแก้ไขไฟล์ pg_hba.conf ที่สร้างขึ้นหลังจากเรียกใช้ initdb ก็ได้

คำสั่ง initdb จะกำหนดค่า locale เริ่มต้นให้ `database cluster` ด้วย โดยปกติแล้ว คำสั่งนี้จะใช้การตั้งค่า locale ในสภาพแวดล้อม และนำไปใช้กับฐานข้อมูลที่เริ่มต้นใช้งาน

ค่าเริ่มต้นลำดับการจัดเรียง ที่ใช้ภายใน `database cluster` นั้น ถูกกำหนดโดย initdb และถึงแม้คุณจะสามารถสร้างฐานข้อมูลใหม่ โดยใช้ลำดับการจัดเรียงที่แตกต่างกันได้ [^1] แต่ลำดับที่ใช้ในฐานข้อมูล template [^2] ที่ initdb สร้างขึ้นนั้นไม่สามารถเปลี่ยนแปลงได้ นอกจากจะลบและสร้างใหม่

การใช้ locale อื่นที่ไม่ใช่ C หรือ POSIX [^3] ยังส่งผลกระทบ ต่อประสิทธิภาพการทำงานเช่นกัน ดังนั้น การเลือกภาษาท้องถิ่น ให้ถูกต้องตั้งแต่ครั้งแรกจึงเป็นสิ่งสำคัญ

คำสั่ง initdb ยังตั้งค่าการเข้ารหัสชุดอักขระเริ่มต้น สำหรับคลัสเตอร์ฐานข้อมูลด้วย โดยปกติแล้วควรเลือกให้ตรงกับ การตั้งค่า locale

locale ที่ไม่ใช่ C และไม่ใช่ POSIX จะอาศัยไลบรารี่การเรียงลำดับ `operating system` ในการจัดเรียงชุดอักขระ ซึ่งควบคุมลำดับของคีย์ ที่จัดเก็บไว้ในดัชนี สิ่งนี้ควบคุมลำดับของคีย์ที่จัดเก็บไว้ในดัชนี ด้วยเหตุนี้ คลัสเตอร์จึงไม่สามารถเปลี่ยนไปใช้ เวอร์ชั่นไลบรารีการเรียงลำดับที่ต่างกันได้ ไม่ว่าจะด้วยวิธีการกู้คืนสแนปช็อต, การจำลองแบบสตรีมมิ่งไบนารี, OS ที่แตกต่างกัน หรือการอัปเกรด OS

```
# 1. ติดตั้งภาษาไทยลงใน OS
sudo locale-gen th_TH.UTF-8

# 2. อัปเดตการตั้งค่าภาษา
sudo update-locale
```

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

ระบบปฏิบัติการที่ต่างกัน ข้อกำหนด (วิธีการ) ในการสั่งให้ Daemon เริ่มทำงานตอนเปิดเครื่อง (Boot) ที่แตกต่างกันออกไป หลายระบบใช้ไฟล์ `/etc/rc.local` หรือ `/etc/rc.d/rc.local` บางระบบใช้ไดเร็กทอรี `init.d` หรือ `rc.d` ไม่ว่าคุณจะทำอย่างไร เซิร์ฟเวอร์จะต้องทำงานโดยบัญชีผู้ใช้ `postgres` ไม่ใช่โดย `root` หรือผู้ใช้อื่นๆ ดังนั้นคุณควรใช้คำสั่ง su postgres -c '...' ตัวอย่างเช่น:

```
su postgres -c 'pg_ctl start -D /usr/local/pgsql/data -l serverlog'
```

หากใช้ systemd คุณสามารถสร้างไฟล์ service ต่อไปนี้ได้ (เช่น ที่ /etc/systemd/system/postgresql.service):

```
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=postgres

ExecStart=/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data
ExecReload=/bin/kill -HUP $MAINPID

KillMode=mixed
KillSignal=SIGINT
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target
```

## systemd RemoveIPC

หากมีการใช้งาน `systemd` ต้องระมัดระวังทรัพยากร `IPC` (รวมถึงหน่วยความจำที่ใช้ร่วมกัน) ไม่ให้ถูกลบโดย `OS` โดยเฉพาะอย่างยิ่งเมื่อติดตั้ง PostgreSQL จากซอร์สโค้ด เพราะการติดตั้งแบบอื่น ผู้ใช้ `postgres` จะถูกสร้างขึ้นเป็น `system user`

การตั้งค่า RemoveIPC จะอยู่ในในไฟล์ logind.conf จะควบคุมว่า IPC จะถูกลบออกหรือไม่ เมื่อผู้ใช้ล็อกเอาต์อย่างสมบูรณ์ (ยกเว้น `system user`)การตั้งค่านี้มีค่าเริ่มต้นเป็น `เปิด` ใน systemd มาตรฐาน แต่ระบบปฏิบัติการบางรุ่น อาจมีค่าเริ่มต้นเป็นปิด

### Footnotes

[^1]: แม้ว่า initdb หากกำหนดค่าเริ่มต้นของ Cluster เป็น en_US ไปแล้ว แต่ PostgreSQL ออกแบบมาให้เราสามารถสร้าง Database ใหม่ที่มีการตั้งค่า Locale ต่างจากค่าเริ่มต้นได้ (เรียกว่าการ Overwrite ค่า Default) แต่เวลาคุณสั่งรัน Tool บางอย่างผ่าน Command Line (เช่น reindexdb หรือ vacuumdb) ถ้าไม่ได้ระบุ Database ให้ชัดเจน มันอาจจะอ้างอิงค่าจาก User Environment แทน

[^2]: โดยปกติเมื่อคุณใช้คำสั่ง CREATE DATABASE name; ตัว PostgreSQL จะไม่ได้สร้างฐานข้อมูลขึ้นมาจากความว่างเปล่า แต่จะทำทำการ "Copy" ไฟล์ทั้งหมดมาจาก Template

[^3]: C หรือ POSIX เรียงตาม Binary ไม่สนภาษา ปลอดภัยที่สุดในการย้ายเครื่อง แต่อาจเรียงภาษาไทยไม่ค่อยดี

```
./configure \
 ICU_CFLAGS="-I/usr/local/icu-custom/include" \
 ICU_LIBS="-L/usr/local/icu-custom/lib -licui18n -licuuc -licudata"

initdb --locale-provider=icu \
--locale-provider=icu \
--icu-locale=th-TH \
--encoding=UTF8
```

```
# นอกเรื่อง
docker exec ghb-pms-postgres pg_dump -U pmsdb pms > uat-backup.sql

docker exec -it gsb-pms-postgres bash

docker cp ~/backupds/prod-backup.sql gsb-pms-postgres:/var/lib/postgresql/

docker cp gsb-pms-postgres:/var/lib/postgresql/data/log/postgresql-2026-03-19_000000.log ./

docker exec gsb-pms-postgres psql -U pmsdb -d pms -f /var/lib/postgresql/ prod-backup.sql

initdb --lc-collate=C --lc-ctype=C -E UTF8

tar --exclude='logs' --exclude='postgres_data' --exclude='backups' -cvjf db-server.tar.bz2 db-server/
```
