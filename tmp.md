## ฝาก

```
./configure \
 ICU_CFLAGS="-I/usr/local/icu-custom/include" \
 ICU_LIBS="-L/usr/local/icu-custom/lib -licui18n -licuuc -licudata"

initdb --locale-provider=icu \
--locale-provider=icu \
--icu-locale=th-TH \
--encoding=UTF8
```
