# SISOP-5-2026-IT-020
## Farrel Arteya Kumara - 5027251020
### Soal 1
#### Struktur Repositori Soal 1
<img width="573" height="144" alt="2026-05-31 14:45:22" src="https://github.com/user-attachments/assets/7d177589-1fa2-43ee-b7c3-2c899725cc92" /> <br/><br/>

#### Deskripsi Program

Program ini dibuat untuk menyelesaikan Soal 1 - Farewell Party pada Praktikum Sistem Operasi Modul 5. Tugas utama dari program ini adalah membuat sistem operasi sederhana yang dapat melakukan boot menggunakan kernel Linux versi 6.1.1, membuat filesystem berbasis BusyBox, mendukung mode single-user dan multi-user, membuat ISO bootable, menjalankan hasil build menggunakan QEMU, serta melakukan backup terhadap file hasil build. <br/><br/>

Sistem operasi sederhana ini memiliki dua mode filesystem:

1. Single-user filesystem
   - Hanya memiliki user root.
   - Password user root adalah root123.
   - Output filesystem disimpan sebagai osboot/single.gz.
2. Multi-user filesystem
   - Memiliki user root, henn, hann, viii, dan kids.
   - Setiap user memiliki password masing-masing.
   - Hak akses setiap user diatur sesuai ketentuan soal.
   - Output filesystem disimpan sebagai osboot/multi.gz.

<br/>Program juga menghasilkan file ISO bootable bernama: <br/>
```bash
osboot/farewell.iso <br/>
```

Selain itu, semua hasil build dapat dibackup menjadi file ZIP dengan format: <br/>
```bash
farewell_backup_[DDMMYYYY-HHMMSS].zip
```
<br/>
Fungsi tiap file: <br/>
## Penjelasan Singkat Setiap File

| File / Folder | Penjelasan                                                                                                                                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `.config`     | File konfigurasi kernel Linux yang digunakan saat proses compile. Konfigurasi ini memastikan kernel mendukung initramfs, filesystem dasar, terminal, jaringan, dan FUSE.                                                                         |
| `kernel.sh`   | Script untuk mendownload Linux kernel versi `6.1.1`, melakukan konfigurasi kernel, mengcompile kernel, lalu menyimpan hasilnya sebagai `osboot/bzImage`.                                                                                         |
| `single.sh`   | Script untuk membuat single-user filesystem berbasis BusyBox. Filesystem ini hanya memiliki user `root` dengan password `root123`, lalu hasil akhirnya dikompres menjadi `osboot/single.gz`.                                                     |
| `multi.sh`    | Script untuk membuat multi-user filesystem berbasis BusyBox. Filesystem ini memiliki user `root`, `henn`, `hann`, `viii`, dan `kids` beserta password dan hak akses direktori sesuai spesifikasi soal. Output akhirnya adalah `osboot/multi.gz`. |
| `iso.sh`      | Script untuk membuat ISO bootable menggunakan GRUB. ISO ini dapat melakukan boot ke dua pilihan filesystem, yaitu single-user dan multi-user. Output akhirnya adalah `osboot/farewell.iso`.                                                      |
| `qemu.sh`     | Script untuk menjalankan OS menggunakan QEMU. Script ini mendukung tiga mode: `--single` untuk boot single-user, `--multi` untuk boot multi-user, dan `--all` untuk boot dari ISO.                                                               |
| `backup.sh`   | Script untuk membackup hasil build, yaitu `bzImage`, `single.gz`, `multi.gz`, dan `farewell.iso`, ke dalam file ZIP dengan format `farewell_backup_[DDMMYYYY-HHMMSS].zip`.                                                                       |
| `osboot/`     | Folder output hasil build. Folder ini berisi kernel hasil compile, filesystem single-user, filesystem multi-user, ISO bootable, dan file backup.                                                                                                 |

<br/>
### kernel.sh
#### Fungsi utama:
1. Mendownload Linux kernel versi 6.1.1.
2. Mengekstrak source kernel.
3. Mengatur konfigurasi kernel.
4. Mengcompile kernel.
5. Menyimpan hasil compile ke: osboot/bzImage

```bash

```
<br/>Jalankan Program: <br/>
<img width="590" height="51" alt="2026-05-31 15:58:47" src="https://github.com/user-attachments/assets/7ba81b2f-36d3-4cf3-88a7-67c35f7eee4a" /> <br/><br/>

<img width="434" height="161" alt="2026-05-31 16:00:08" src="https://github.com/user-attachments/assets/ed61e461-5d7d-4593-a0de-c9684307d95e" /> <br/><br/>

<img width="500" height="92" alt="2026-05-31 16:01:20" src="https://github.com/user-attachments/assets/fedf4dae-a414-489a-828b-d50af3998f77" /> <br/><br/>

Jalankan, <br/>
```bash
./single.sh
./multi.sh
./iso.sh
```
Cek file apakah sudah ada setelah menjalankan perintah diatas, <br/>
```bash
ls -lh osboot/bzImage osboot/single.gz osboot/multi.gz osboot/farewell.iso
```

<br/>

Jalankan,

```bash
./qemu.sh --all
```
<img width="943" height="1010" alt="2026-05-31 16:05:38" src="https://github.com/user-attachments/assets/e10149cc-0642-449f-93ac-00d80372d930" /> <br/>

Pilih salah satu. <br/><br/>

#### Untuk Single User: <br/>
Login: 
```bash
login: root
password: root123
```
Tes:
```bash
whoami
ls /
party list
party install hello
/bin/hello-party
fuse_test
ping 8.8.8.8
wget example.com
uname -r
```

Hasil, <br/>
<img width="945" height="1011" alt="2026-05-31 16:10:58" src="https://github.com/user-attachments/assets/abdfc2d2-92ec-4ab5-bcb7-7f98c3dfd1c6" /> <br/>
<img width="943" height="1010" alt="2026-05-31 16:12:14" src="https://github.com/user-attachments/assets/e88fbcfb-6550-4eb4-b91f-023060a1617b" /> <br/>

Setelah selesai jalankan,
```bash
exit
```
Untuk keluar dan lanjut ke Multi User. <br/><br/>

#### Untuk Multi User: <br/>

###### 1. Tes user root (memiliki akses penuh ke directory)

Login: 
```bash
login: root
password: root123
```
Tes: 
```bash
whoami

cd /root
pwd

cd /home/henn
pwd

cd /home/hann
pwd

cd /home/viii
pwd

cd /home/kids
pwd
```
User root harus bisa mengakses semua directory.<br/>
<img width="354" height="228" alt="2026-05-31 16:54:22" src="https://github.com/user-attachments/assets/d4d0db93-9aed-4a0a-bf40-70d5096c22f9" /> <br/><br/>

##### 2. Tes user henn (hanya memiliki akses ke /home/*)

Login:
```bash
login: henn
password: henn123
```
Tes:
```bash
whoami

cd /home/henn
pwd

cd /home/hann
pwd

cd /home/viii
pwd

cd /home/kids
pwd
```
User henn harus bisa mengakses semua directory kecuali /root. <br/>
<img width="362" height="243" alt="2026-05-31 16:55:19" src="https://github.com/user-attachments/assets/9597f590-3afa-49e9-9c44-08385c0bc8e4" />

<img width="432" height="246" alt="2026-05-31 16:43:20" src="https://github.com/user-attachments/assets/1527e95d-3480-48ef-9121-83fdd103a5cb" /> <br/><br/>

##### 3. Tes user hann (hanya memiliki akses ke /home/{hann,vii,kids})

Login:
```bash
login: hann
password: hann123
```
Tes:
```bash
whoami

cd /home/hann
pwd

cd /home/viii
pwd

cd /home/kids
pwd
```
User hann harus bisa mengakses semua directory kecuali /root & /home/henn. <br/>
<img width="362" height="249" alt="2026-05-31 16:56:07" src="https://github.com/user-attachments/assets/ce2a4a34-f82e-4a76-8bfe-37d1f1377303" />

<img width="470" height="252" alt="2026-05-31 16:45:43" src="https://github.com/user-attachments/assets/8a0f31d8-bc53-4082-ac50-b6aa60d3da7c" /> <br/><br/>

##### 4. Tes user viii (hanya memiliki akses ke /home/{vii,kids})

Login:
```bash
login: viii
password: viii123
```
Tes:
```bash
whoami

cd /home/viii
pwd

cd /home/kids
pwd
```
User viii hanya bisa mengakses /home/viii & /home/kids. <br/>
<img width="362" height="249" alt="2026-05-31 16:56:07" src="https://github.com/user-attachments/assets/af12b562-9a20-4253-aa5d-1919640955ee" />

<img width="467" height="278" alt="2026-05-31 16:47:27" src="https://github.com/user-attachments/assets/3707d59c-a062-4b69-9faf-7b9b0e7995a9" /> <br/><br/>

##### 5. Tes user kids (hanya memiliki akses ke /home/kids)

Login:
```bash
login: kids
password: kids123
```
Tes:
```bash
whoami

cd /home/kids
pwd
```
User kids hanya bisa mengakses /home/kids. <br/>
<img width="362" height="249" alt="2026-05-31 16:56:07" src="https://github.com/user-attachments/assets/eef071a6-1fba-477a-adfa-92796de1f978" /> <br/>

<img width="463" height="309" alt="2026-05-31 16:49:11" src="https://github.com/user-attachments/assets/d3ef4188-4994-4e83-ad8e-348e0406e554" /> <br/><br/>

Setelah selesai jalankan,
```bash
exit
```






