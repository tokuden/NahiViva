# NahiViva (なひビバ)
Vivadoを使っていて、次のような悩みはないですか？

<span style="font-size: 150%;">
「このプロジェクトはVivado 2018.3用なんだけど、わざわざ古いVivadoをスタートメニューから開くのが面倒くさいな」

「Update IPの作業って、どうしてこんなに何度も何度もクリックしなきゃいけないの？」

「MCSファイルって、どうやって作るんだっけ」

「gitでプロジェクトを管理したいけど、ブロックデザインもプロジェクトもバイナリだから相性が悪いな」

「テレワークしようと会社のファイルを家に持って帰ってきたけど、ディレクトリ関係が変わってやりにくい」

「そもそもBitStreamってどこにあるの？」

「お客さんに300Mバイトのプロジェクトをメールで送ったら怒られた」

</span>

NahiVivaはそんな悩みを解決する、Vivadoの操作のための便利Tclライブラリです。

主に次のようなことがコマンド一発でできます。

* [論理合成・配置配線の実行](#NahiRun　(論理合成・配置配線))
* [Update-IP作業の自動化](#NahiUpdate (IPのアップデート))
* [SPI-ROM用のMCSファイル生成](#NahiGenMcs (MCSファイルの作成))
* [Vivadoのバージョンを指定して起動](#起動方法)
* [コメントを利用したIPの一括カスタマイズ](#NahiConfigByComments (コメントからのIPカスタマイズ))
* [BitStreamを見つけやすいフォルダにコピー](#NahiCopyBit (Bitファイルを表に出す))
* [Tcl形式でのプロジェクト保存](#NahiSave (アーカイブ保存))

# 動作環境
- XILINX Vivado 2017.4 2018.1 2018.2 2018.3 2018.4 2019.1 2019.2 2020.1 2020.2
- Windows 10で動作確認済み (Linuxはまた別途)

# セットアップ
VivadoのXPRファイルがあるフォルダの1つ上のフォルダに、NahiVivaのファイル一式を置きます。  
（少なくともnahiviva.tcl、open_project_gui.cmd、SETTINGS.CMDの3つがあれば動作可能）

インストールされているVivadoに合わせて、SETTINGS.CMDを編集します。

```SETTINGS.CMD
@SET VIVADO_PATH=D:\Xilinx\Vivado\
@SET VIVADO_VERSION=2019.2
```
ここで設定したパスの、指定したバージョンのVivadoを使用するようになります。

# 起動方法

open_project_gui.cmdをクリックします。  
フォルダ内でVivadoのプロジェクトを探し、Vivadoが起動します。

## 動作中のVivadoから読み込む方法

Tclコンソールからsourceコマンドを使って、nahiviva.tclを読み込んでください。ファイルのパスにご注意ください。
```
source ./nahiviva.tcl
```

# 様々な便利コマンド

VivadoのTclコンソールに以下のコマンドを入力することで、様々な強化機能が使えるようになります。

## NahiRun　(論理合成・配置配線)
このコマンドは、Vivadoの論理合成を行います。
```
NahiRun [オプション]
```
オプションに-updateを指定した場合は、Update IPの動作を一緒に行います。

オプションに-restartを指定した場合は、論理合成済みであっても、最初から論理合成と配置配線を行います。

オプションに-synthを指定した場合は、論理合成のみ行い、配置配線は行いません。

オプションに-reportを指定した場合は、使用率レポート、タイミングレポート、IOレポートを作成します。   

## NahiUpdate (IPのアップデート)

IPコアのソースを変更した場合、IP StatusをしてRunしたりUpdate IPといった一連の操作は面倒ですが、NahiUpdateコマンドを使用するとダイアログを出すことなくUpdate IPの動作をすべて行います。

```
NahiUpdate
```

## NahiShowAllProperty (プロパティを全部見る)
オブジェクトにはいろいろなプロパティがあります。具体的に言うと、クロックの配線、特定のプリミティブ、プロジェクトなど、すべてがオブジェクトです。
こういったオブジェクトのプロパティを全部見るのがこのコマンドです。

```
NahiShowAllProperty　[オブジェクト名]
```

## NahiSave (アーカイブ保存)
Vivadoのプロジェクトをアーカイブとしてを保存し、BDやMIG、IPなどのGUI生成オブジェクトも含めてTCL形式で保存します。
```
NahiSave
```
これによってすべてのVivadoプロジェクトがテキスト化されるため、gitでのバージョン管理が容易になります。

## NahiConfigByComments (コメントからのIPカスタマイズ)
たくさんのIPコアを作っているとカスタマイズが面倒になることが多々あります。例えば、ADコンバータを使った計測システムでは、ADCインタフェースモジュール、ピーク検出モジュール、DMAモジュールなど様々なモジュール間をAXI Stereamでインターフェースするとします。

この場合、ADCの分解能を変更したい場合、すべてのIPのGUI設定画面をひらき、パラメータを変更することになりますが設定漏れがあると論理合成中にエラーとなってしまうでしょう。

また、FPGAのバージョン番号などをIPにパラメータとして設定した場合、わざわざIPの設定画面を開いて変更するのも面倒です。

そこで、Vivadoのコメント機能を使ってパラメータを一括で変更できるようにしました。

```
NahiConfigByComments
```

## NahiGenMcs (MCSファイルの作成)
BitStreamをSPI ROMに書き込むためのMCSファイルに変換します。

```
NahiGenMcs [オプション]
```
オプションに-x1 -x2 -qspiを付けると、SPI ROMをx1、x2、-4でコンフィグします。デフォルトではx2です。
ｖｖｖｖ
オプションに-4m -8m -16m -32m -64m -128mを付けると、ROMのサイズがあふれた場合に知らせてくれます。デフォルトでは32M(N25Q256相当)です。

## NahiCopyBit (Bitファイルを表に出す)

VivadoではBitStreamは、\<project>\<project>.runs\impl_1/<project>.bit という深いディレクトリにBitStreamが作られます。これを表のディレクトリにコピーするのがこのコマンドです。
```
NahiCopyBit
```
 
# Author
なひたふ Twitter: @nahitafu

特殊電子回路株式会社

# License
未定(BSDかな)
