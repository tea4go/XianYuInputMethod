/**
 * 最顶部的正在输入的消息框
 */
import { KeyButtonData } from '../data/KeyButtonDataManager'
import { inputMethod } from '@kit.IMEKit'
import { PinyinSuggestResult, spellToWord } from '../util/SpellToWordUtil'
import keyboardController from '../model/KeyboardController'
import {PinyinDataSource, WordSuggestDataSource} from "../dao/DataSouce"
import { util } from '@kit.ArkTS'
import { FaultLogger } from '@kit.PerformanceAnalysisKit'
import Logger from '../util/Logger'
import { US_SUB_TYPE_ID } from '../constant/InputMethConstant'

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
  @Consume @Watch("onPreviewTextUpdate") useWords:Array<SuggestionWord>
  // 联想词资源
  // @State words:Array<SuggestionWord> = []
  @Consume pinyinList: PinyinDataSource;

  suggestWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage:boolean;

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
   * 已使用的按键更新（新增或删除）
   */
  onPreviewTextUpdate(){
    this.getShowInputContent()
  }

  /**
   * 顶部的正在输入内容
   */
  @Builder
  smartSuggestionText() {
    // 顶部的正在输入内容
    Row() {
      Text(){
        ForEach(this.getShowInputContent(), (item:PreviewText, index)=>{
          Span(item.str).decoration({type: item.lock?TextDecorationType.Underline:TextDecorationType.None})
        }, (item:PreviewText, index)=> item.str + index)
      }.margin({ left: 16 }).fontSize(14).fontColor(Color.Black)

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
          LazyForEach(this.suggestWords, (item:SuggestionWord, index)=>{
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
          this.showPinYinListPage = true;
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
  getShowInputContent(): Array<PreviewText> {
    let showText: Array<PreviewText> = []

    // 已使用的联想词列表
    let useIndex = this.useWords.length
    this.useWords.forEach((value, index)=>{
      showText.push(new PreviewText(value.showName, true))
    })

    this.inputContent.forEach((value, index) =>
    {
      if(0 == index){
        // 判断第一个联想词
        let firstSuggestWordGroup = this.suggestWords
        if(firstSuggestWordGroup && firstSuggestWordGroup.totalCount() > 0){
          let firstWord = firstSuggestWordGroup.getData(0).previewText
          showText.push(new PreviewText(firstWord.charAt(0)+"'", false))
        }else{
          if (value.fillStr) {
            showText.push(new PreviewText(value.fillStr.charAt(0), false))
          }
        }

      }else if( useIndex != 0 && index > useIndex){
        if (value.fillStr) {
          showText.push(new PreviewText(value.fillStr.charAt(0), false))
        }
      }
    })
    return showText
  }

  /**
   * 输入内容更新时调用事件
   */
  onInputUpdate(){
    let suggestWords = getAssociationWord(this.inputContent)
    Logger.info(`共查询到${suggestWords.words.length}个联想词`)
    this.pinyinList.replaceAllData(suggestWords.pinyin)
    if(this.pinyinList.totalCount() == 0){
      this.showPinYinListPage = false
    }
    this.suggestMode = suggestWords.words.length > 0
    this.suggestWords.replaceAllData(suggestWords.words)
  }

}

/**
 * 预览文本
 */
export class PreviewText{
  // 显示内容
  str:string = ''
  // 是否已锁定
  lock:boolean = false;

  constructor(str: string, lock: boolean) {
    this.str = str
    this.lock = lock
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
function getAssociationWord(keyWord:KeyButtonData[]):PinyinSuggestResult{
  if(keyWord.length == 0){
    return {pinyin: [], words: []}
  }
  let subType = inputMethod.getCurrentInputMethodSubtype()
  let englishMode = subType.id == US_SUB_TYPE_ID
  let result = spellToWord(keyWord, englishMode)
  return result
}

