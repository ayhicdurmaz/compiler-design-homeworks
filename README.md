# MiniGo Parser

Bu proje, MiniGo dilinin parser’ını ve Abstract Syntax Tree (AST) oluşturucusunu içeriyor. Flex tabanlı lexer’ın üzerine Bison ile yazılmış bir parser ekleniyor ve çalıştırıldığında MiniGo kaynak kodundan AST üretiyor. Aşağıdaki bölüm yalnızca projeyi nasıl derleyip test edeceğinizi açık ve basit bir şekilde anlatır.

## Gerekli Araçlar

Sistemde Flex, Bison ve C derleyicisi bulunmalı. Ubuntu/Debian tabanlı bir sistemde kurmak için:

sudo apt-get install flex bison build-essential

## Derleme

Projeyi derlemek için:

make


Manuel derlemek isterseniz:

bison -d parser.y
flex lexer.l
gcc -Wall -Wextra -std=c99 -g -o minigo_parser parser.tab.c lex.yy.c ast.c -lm


Çıktı olarak minigo_parser adlı çalıştırılabilir dosya oluşur.

## Parser’ı Çalıştırma

Bir MiniGo dosyasını parse etmek için:

./minigo_parser dosya.mg


Örneğin:

./minigo_parser test1.mg


Parser hatasız çalışırsa önce "Parse successful!" yazısı gelir, ardından AST ekrana dökülür.

## Hazır Testleri Çalıştırma

Projeyle birlikte gelen testleri çalıştırmak için:

make test


Bu komut genelde test1.mg, test2.mg, test3.mg gibi örnek programları otomatik olarak parser’a gönderir.

## Hatalı Programları Test Etme

Sözdizimi hatalarının nasıl raporlandığını görmek için:

./minigo_parser test_errors.mg


Parser, hangi satırda hangi hatanın görüldüğünü bildirir. Bu dosya, doğru hata mesajlarını alıp almadığınızı kontrol etmek için hazırlanmıştır.

## Temizlik

Oluşan geçici dosyaları silmek için:

make clean


Bu komut, Bison ve Flex tarafından üretilen dosyaları ve derlenmiş çıktıları temizler.
