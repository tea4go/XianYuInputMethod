import { spellToWord } from '../../cncharInput/cnchar/util/SpellToWordUtil';
import keyboardController from '../model/KeyboardController';
import { InputToolBar } from '../view/InputTool';
import { InputButtonData, MainInputPanel } from '../view/MainInputPanl';
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


/**
 * 获取联想词
 * @returns
 */
function getAssociationWord(keyWord:string[]):Array<string>{
  let result:string|string[] = spellToWord(keyWord)
  return result as string[]
  //return ["你好", "您好", "你还", "(*´▽｀)ノノ"]
}

@Component
@Preview
export struct InputTool {

  @Consume @Watch("onInputUpdate")  inputContent:Array<InputButtonData>
  // 是否展示联想词
  @State words:Array<string> = []

  build() {
    Row() {
      if(this.words.length > 0){
        List(){
          ForEach(this.words, (item:string, index)=>{
            ListItem(){
              Button(item).type(ButtonType.Normal).backgroundColor(Color.Transparent)
                .fontColor(Color.Black)
                .height('100%')
                .onClick(() => {
                  // 添加文字进入输入框
                  keyboardController.insertText(item);
                  // 清空已输入按键
                  this.inputContent = []
                })
            }
          }, (item:string, index:number)=> item)
        }.layoutWeight(1).height('100%').padding(5).listDirection(Axis.Horizontal)

        Button(){
          Image($r('app.media.to_right'))
        }.width(40).height(40).backgroundColor(Color.Transparent)
        .onClick(()=>{
          // TODO 切换具体读音界面
        })


      }else{
       InputToolBar()
      }
    }.width('100%').height(40).justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.Transparent)
  }

  onInputUpdate(){
    this.words = getAssociationWord(this.getInputStrArray())
  }

  getInputStrArray():string[]{
    let result:Array<string> = []
    if(this.inputContent){
      this.inputContent.forEach((value, index)=>{
        let fillStr = value.fillStr
        if(fillStr){
          result.push(fillStr)
        }
      })
    }

    return result
  }
}

@Component
export struct BottomTool {
  build() {
    Row() {
      Button(){
        Image($r('app.media.keyboard')).width(40).height(40)
          .padding(5)
      }.backgroundColor(Color.Transparent)
      .width(40).height(40)

      Blank()
      Button(){
        Image($r('app.media.paste'))
          .padding(8)
      }.backgroundColor(Color.Transparent)
        .width(40).height(40)
    }.width('100%').height(40)
    .backgroundColor(Color.Transparent)
    .padding({left:16, right: 16, top: 2})
  }
}

@Component
export struct TopTextTip{
  @Consume inputContent:Array<InputButtonData>
  build() {
    Row(){
      Text(this.getShowInputContent()).fontSize(14).fontColor(Color.Black)
        .margin({left: 16 })
    }.height(30).width('100%')
    .backgroundColor(Color.Transparent).justifyContent(FlexAlign.Start)
  }

  /**
   * 获取展示在输入顶上的正在输入的字符
   * @returns
   */
  getShowInputContent():string{
    let showText:string = ""
    this.inputContent.forEach((value, index)=>{
      if(value.fillStr){
        showText+=value.fillStr.charAt(0).toLowerCase()
      }

    })
    return showText
  }
}


@Component
@Entry
struct InputIndex {
  // 记录输入的键值
  @Provide inputContent:Array<InputButtonData> = []
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
            TopTextTip()
            InputTool()
            MainInputPanel()
            BottomTool()
          }.width('100%').height('100%')

        }
        .align(Alignment.End)
        .width("100%")
        .height("100%")
      }
      .height("100%").align(Alignment.End).backgroundColor("#eff0f4")


    }
    .position({ x: 0, y: 0 }).zIndex(99999)
  }
}

