import keyboardController from '../model/KeyboardController';
import { MainInputPanel } from '../view/MainInputPanl';
import { numberSourceListData, sourceListType } from './keyboardKeyData';


@Component
export struct keyItem {
  private keyValue: sourceListType = numberSourceListData[0];
  @State keyBgc: string = "#fff"
  @State keyFontColor: string = "#000"

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center
      }) {
        Text(this.keyValue.content).fontSize(20).fontColor(this.keyFontColor)
      }
    }
    .backgroundColor(this.keyBgc)
    .borderRadius(6)
    .width("8%")
    .height("65%")
    .onClick(() => {
      keyboardController.insertText(this.keyValue.content);
    })
  }
}

// 删除组件
@Component
export struct deleteItem {
  @State keyBgc: string = "#fff"
  @State keyFontColor: string = "#000"

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center
      }) {
        Text("删除").fontSize(20).fontColor(this.keyFontColor)
      }
    }
    .backgroundColor(this.keyBgc)
    .width("13%")
    .borderRadius(6)
    .onClick(() => {
      keyboardController.deleteForward(1);
    })
  }
}

// 数字键盘
@Component
struct numberMenu {
  private numberList: sourceListType[] = numberSourceListData;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.numberList, (item: sourceListType) => { // 数字键盘第一行
          keyItem({ keyValue: item })
        }, (item: sourceListType) => item.content);
      }
      .padding({ top: "2%" })
      .width("96%")
      .height("25%")

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        deleteItem()
      }
      .width("96%")
      .height("25%")
    }
  }
}

/**
 * 获取联想词
 * @returns
 */
function getAaaWord(keyWord:string):Array<string>{
  return ["你好", "您好", "你还", "(*´▽｀)ノノ"]
}

@Component
@Preview
export struct InputTool {
  // 是否展示联想词
  @State isShowWords:boolean = true
  @State words:Array<string> = getAaaWord('nh')

  build() {
    Row() {
      if(this.isShowWords){
        Row({space: 5}){
          ForEach(this.words, (item:string, index:number)=>{
            Button(item).type(ButtonType.Normal)
            .height('100%')
            .onClick(() => {
              keyboardController.insertText(item);
            })
          }, (item:string, index:number)=> item)
        }.width('100%').height('100%').justifyContent(FlexAlign.SpaceAround)

      }else{
        Button('1').backgroundColor(Color.Transparent)
        Button('1').backgroundColor(Color.Transparent)
        Button('1').backgroundColor(Color.Transparent)
        Button('1').backgroundColor(Color.Transparent)
        Button('1').backgroundColor(Color.Transparent)
        Button('1').backgroundColor(Color.Transparent)
      }
    }.width('100%').height(40).justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.Orange)
  }
}

@Component
export struct BottomTool {
  build() {
    Row({ space: 5 }) {
      Button('1').backgroundColor(Color.Transparent)
      Blank()
      Button("2").backgroundColor(Color.Transparent)
    }.width('100%').height(40)
  }
}



@Component
@Entry
struct InputIndex {
  private numberList: sourceListType[] = numberSourceListData

  build() {
    Stack() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.End
      }) {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Column({ space: 5 }) {
            InputTool()
            MainInputPanel()
            BottomTool()
          }.width('100%').height('100%')

          /*numberMenu({
            numberList: this.numberList
          })*/
        }
        .align(Alignment.End)
        .width("100%")
        .height("75%")
      }
      .height("100%").align(Alignment.End).backgroundColor("#cdd0d7")
    }
    .position({ x: 0, y: 0 }).zIndex(99999)
  }
}

