/**
 * 最顶部的正在输入的消息框
 */
import { KeyButtonData } from '../data/KeyButtonDataManager'
import { inputMethod } from '@kit.IMEKit'
import { PinyinSuggestGroup, spellToWord } from '../../cncharInput/cnchar/util/SpellToWordUtil'
import keyboardController from '../model/KeyboardController'
import {WordDataSource} from "../dao/DataSouce"
import { util } from '@kit.ArkTS'
import { FaultLogger } from '@kit.PerformanceAnalysisKit'
import Logger from '../util/Logger'

/**
 * 智能联想栏
 */
@Component
export struct SmartSuggestionBar {
  // @State inputContent:Array<KeyButtonData> = []

  // @State @Watch("onInputUpdate")  inputContent:Array<KeyButtonData> = []
  @Consume @Watch("onInputUpdate")  inputContent:Array<KeyButtonData>
  // 是否展示联想词
  @State suggestMode:boolean = false;
  // 已选中的联想词
  @State useWords:Array<SuggestionWord> = []
  // 联想词资源
  // @State words:Array<SuggestionWord> = []
  @Consume words: WordDataSource;

  build() {
    Row(){
      Column(){
        // 顶部的正在输入内容
        this.smartSuggestionText()
        // 联想词列表
        this.suggestionList()
      }.width('100%')
    }.width('100%')
  }

  /**
   * 顶部的正在输入内容
   */
  @Builder
  smartSuggestionText() {
    // 顶部的正在输入内容
    Row() {
      Text(this.getShowInputContent()).fontSize(14).fontColor(Color.Black)
        .margin({ left: 16 })
    }.height(30).width('100%')
    .backgroundColor(Color.Transparent).justifyContent(FlexAlign.Start)
  }



  /**
   * 联想词列表
   */
  @Builder suggestionList(){
    Row() {
      if(this.suggestMode){
        List(){
          LazyForEach(this.words, (item:SuggestionWord, index)=>{
            ListItem(){
              Button(item.showName).type(ButtonType.Normal).backgroundColor(Color.Transparent)
                .fontColor(Color.Black)
                .height('100%')
                .onClick(() => {
                  // 添加文字进入输入框
                  keyboardController.insertText(item.showName);
                  // 清空联想词相关按键
                  this.updateKeyButtonData(item.keys)
                })
            }
          }, (item:SuggestionWord, index:number)=> item.id)
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

  /**
   * 更新已选择的联想词状态为已选择, 不再参与词语联想
   * @param keys
   */
  updateKeyButtonData(keys:KeyButtonData[]){
    keys.forEach((value, index)=>{
      value.createWord = true
    })

    // 判断本次输入是否已完成
    let completeInput:boolean = true;
    for (let index = 0; index < this.inputContent.length; index++) {
      if(!this.inputContent[index].createWord){
        completeInput = false
        break
      }
    }
    // 输入完成，清空已输入按钮
    if(completeInput){
      this.inputContent = []
    }
  }

  /**
   * 获取展示在输入顶上的正在输入的字符
   * @returns
   */
  getShowInputContent(): string {
    let showText: string = ""


    // 已使用的联想词列表
    let useIndex = this.useWords.length
    this.useWords.forEach((value, index)=>{
      showText+= value.showName + ""
    })

    this.inputContent.forEach((value, index) =>
    {
      if(0 == index){
        // 判断第一个联想词
        let firstSuggestWordGroup = this.words.getData(0)
        if(firstSuggestWordGroup){
          let firstWord = firstSuggestWordGroup.pinyin
            showText+= firstWord + "'"
        }else{
          if (value.fillStr) {
            showText += value.fillStr.charAt(0)
          }
        }

      }else if(index > useIndex){
        if (value.fillStr) {
          showText += value.fillStr.charAt(0)
        }
      }
    })
    return showText
  }

  onInputUpdate(){
    let suggestWords = getAssociationWord(this.inputContent)
    Logger.info(`共查询到${suggestWords.length}个联想词`)
    this.words.replaceAllData(suggestWords)
    this.suggestMode = this.words.totalCount() > 0
  }

}



/**
 * 键盘上方的工具栏
 */
@Component
@Preview
export struct InputToolBar{

  @State bgRes:Array<Resource> = [$r('app.media.app_center'), $r('app.media.keyboard_2'), $r('app.media.face'), $r('app.media.guangbiao_move'), $r('app.media.voice_2')]

  build() {
    Row(){
      ForEach(this.bgRes, (item:Resource,index:number)=>{
        Button(){
          Image(item).padding(index==3?8:5)
            .fillColor(Color.Black)
        }.width(40).height(40)
        .type(ButtonType.Normal).backgroundColor(Color.Transparent)
        .onClick(()=>{

        })

      }, (item:Resource, index:number)=> index + '')

    }.width('100%').height(30).justifyContent(FlexAlign.SpaceBetween)
    .padding({left: 16, right: 16})
    .backgroundColor(Color.Transparent)
  }
}

/**
 * 联想词
 */
export class SuggestionWord{
  // 展示的名称
  showName:string = '';
  // 预输入文本(正在输入的框展示的字符串)
  previewText:string = ''
  // 按键组（表示由哪些的输入的按键构成)
  keys:Array<KeyButtonData> = []

  id:string = ''

  constructor(showName: string, previewText: string, keys: Array<KeyButtonData>) {
    this.showName = showName
    this.previewText = previewText
    this.keys = keys
    this.id = util.generateRandomUUID()
  }


}

/**
 * 获取联想词
 * @returns
 */
function getAssociationWord(keyWord:KeyButtonData[]):Array<PinyinSuggestGroup>{
  let subType = inputMethod.getCurrentInputMethodSubtype()
  let englishMode = subType.id == 'UsInputMethodExtAbility'

  let result:PinyinSuggestGroup[] = spellToWord(keyWord, englishMode)
  return result
  //return ["你好", "您好", "你还", "(*´▽｀)ノノ"]
}

