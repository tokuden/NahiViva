# NahiViva (なひビバ)
Vivadoの操作を自動化します。
論理合成や配置配線だけではなく、子IPを更新した際のReport->Report IP StatusからUpdate Selectedと
それに続くダイアログのキャンセルなど、面倒な操作をスクリプトでできるようにします。
- Tclで保存されたプロジェクトの読み込み
- 論理合成と配置配線
- 子IPのUpdate処理
- 子IPを新規Vivadoで開く
- 子IPのRePackage作業
- プロジェクトをTcl形式で保存

# Dependency
- XILINX Vivado 2018.3 (他のバージョンでも可)
Windows 10で動作確認済み

# 使い方
このスクリプトには2つの使い方があります。
1つ目は論理合成や子IPのアップデートの機能だけを使う方法。もう一つはこのスクリプトにプロジェクトの管理をすべて任せる方法です。
まずは、簡単な論理合成とIPのアップデートだけを使う方法を説明します。
## セットアップ (簡単版)
まず、githubから全体をダウンロードするか、下記のスクリプトのみをダウンロードします。
https://raw.githubusercontent.com/tokuden/NahiViva/master/scripts/nahiviva.tcl
(右クリックでファイル保存してください。)

そして、Vivadoのプロジェクトがある任意のフォルダにnahiscript.tclを保存します。

## 起動
Vivadoを起動したら、Tclコンソールに
source nahiviva.tcl
と入力します。人によっては../nahiviva.tclだったり、scripts/nahiviva.tclだったり違うフォルダに置いているかもしれません。
[Nahiviva_3]

これで、使用する準備が整いました。
## 子IPの更新
Vivadoで子IPを更新したら、憎きこの通知が出るでしょう。↓
[Nahiviva_4]

普通ならRefresh IP Catalogを押して、ReRunを押して、Upgrade Selectedを押して、Generate Output ProductsのダイアログでSkipを押して、再度ReRunを押すという面倒なプロセスが待っているのですが、

[Nahiviva_5][Nahiviva_6]

これからは、tclコンソールで、
''NahiUpdate''
と入力するだけです。(NahiUまででOK)

[Nahiviva_7]

上の一連の操作をスクリプトが自動的に行います。面倒なダイアログでボタンを押す必要もありません。

## ビルド(論理合成と配置配線)

論理合成と配置配線およびBitStreamの生成は、Tclコンソールに
''NahiRun [オプション]''
と入力するだけでできます。

下の図のように複数のRUNが存在している場合でも、アクティブなRUNを探して自動的に実行してくれます。
常にRUNを最初からやり直すのではなく、途中までできている場合には途中から開始します。(もちろん最初からやり直すこともできる)

[Nahiviva_8]

## オプションには以下のようなものがあります。

 - -update  コアの更新も一緒に行う
 - -restart  Runをリセットして、最初から開始する
 - -report   使用率、タイミング、IOのレポートを作成する

終了したらBitStreamファイルをプロジェクトのフォルダの上までコピーします。

Vivadoは生成したBitStreamを<project>\<project_1.runs>\<impl_x>\という深いフォルダに保存してしまうので、とても探しにくくなります。また、Runをリセットしたり再度Runするとbitファイルが消されてしまいます。
このスクリプトは<project>のディレクトリまでコピーするので、
 - bitファイルが探しやすくなる
 - 再度Runしたときにも前のbitファイルが消されない
というメリットもあります。

## プロジェクトを開く

DOSのバッチファイルからプロジェクトを開くこともできます。
レポジトリをダウンロードしたら、これらのファイルをVivadoのプロジェクトのあるフォルダか、その一つ上のフォルダに置きます。

[Nahiviva_9]

そして、SETTINGS.CMDを編集します。SETTINGS.CMDの内容は

'''@SET VIVADO_PATH=D:\Xilinx\Vivado\
@SET VIVADO_VERSION=2018.3'''

という簡単なものですが、ここにVivadoをインストールしたフォルダのパスと、Vivadoのリビジョンを設定します。

そして、open_project.cmdまたはopen_project_gui.cmdのアイコンをクリックします。

このコマンドファイルを実行すると、現在のディレクトリと同じか、一つ下のディレクトリからxprファイルを探してそれを指定されたバージョンのVivadoで開きます。Vivadoをたくさん入れている方でも、指定したバージョンのVivadoで開くことができます。

open_project.cmdを実行するとVivadoがテキストモードで開きます。開いたらNahiRunを実行すると論理合成をしてBitファイルが生成されます。

[Nahiviva_10]

open_project_gui.cmdを実行すると見慣れたVivadoのGUIが起動します。

GUIの起動は時間がかかるので、論理合成をするだけならテキストモードで実行したほうが早いでしょう。
 
# Author
なひたふ
# License
まだ決めていない
