/**
 * 最顶部的正在输入的消息框
 */
import { KeyButtonData } from '../data/KeyButtonDataManager'
import { inputMethod } from '@kit.IMEKit'
import { convert2SuggestWord, getKeyMap, isFullPinyin, PinyinSuggestResult, spellToWord } from '../util/SpellToWordUtil'
import keyboardController from '../model/KeyboardController'
import {PinyinDataSource, WordSuggestDataSource} from "../dao/DataSouce"
import { util } from '@kit.ArkTS'
import { FaultLogger } from '@kit.PerformanceAnalysisKit'
import Logger from '../util/Logger'
import { US_SUB_TYPE_ID } from '../constant/InputMethConstant'
import WordService from '../dao/WordsService'
import { smartSelectChar, smartSetNextStrSeg } from '../data/PinYinTrieNode'

/**
 * 智能联想栏
 */
interface IPreviewText {
  previewTextArray: Array<PreviewText>;
  previewStr: string;
}

@Component
export struct SmartSuggestionBar {
  // @State inputContent:Array<KeyButtonData> = []

  // @State @Watch("onInputUpdate")  inputContent:Array<KeyButtonData> = []
  @Consume @Watch("onInputUpdate")  inputContent:Array<KeyButtonData>
  // 是否展示联想词
  @State suggestMode:boolean = false;
  // 已选中的联想词
  @Consume  useWords:Array<SuggestionWord>
  // 联想词资源
  // @State words:Array<SuggestionWord> = []
  @Consume pinyinList: PinyinDataSource;

  suggestWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage:boolean;
  @Consume pageWords:Array<SuggestionWord>
  @Consume @Watch("onInputUpdate") previewTextUpdate:boolean;
  @State previewTextList:Array<PreviewText> = []

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
      Row(){
        List(){
          ForEach(this.previewTextList, (item:PreviewText, index:number)=>{
            ListItem(){
              Text(item.str).decoration({type: item.lock?TextDecorationType.Underline:TextDecorationType.None})
                .fontSize(14).fontColor(Color.Black)
            }
          }, (item:PreviewText, index)=> item.id)
        }.listDirection(Axis.Horizontal).backgroundColor(Color.Transparent)
        .alignListItem(ListItemAlign.Center)
      }.height('100%').backgroundColor('#ecf3fd').constraintSize({maxWidth: '50%'})
      .justifyContent(FlexAlign.Center)
      .margin({ left: 16 })
      .padding({left: 2, right:2})
      Blank()
    }.height(40).width('100%')
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
                .fontColor(0 == index ?'#437fe5':Color.Black)
                .height('100%')
                .onClick(() => {
                  // 添加文字进入输入框
                  keyboardController.insertText(item.showName);
                  // 清空联想词相关按键
                  this.updateKeyButtonData(item.keys)
                  this.useWords.push(item)
                  this.previewTextUpdate = !this.previewTextUpdate
                })
            }
          }, (item:SuggestionWord, index:number)=> item.id)
        }.layoutWeight(1).height('100%').padding(5).listDirection(Axis.Horizontal)

        Button(){
          Image($r('app.media.to_right'))
        }.width(40).height(40).backgroundColor(Color.Transparent)
        .onClick(()=>{
          this.showPinYinListPage = true;
          let firstPinyin:string = this.pinyinList.getData(0)?.name
          // 加载第一页文字
          if(isFullPinyin(firstPinyin)){
             WordService.queryByKeyword(firstPinyin, (words)=>{
               let keyMap = this.pinyinList.getPinYinKeyMap()
              this.pageWords = convert2SuggestWord(keyMap, words)
            })

          }else{
            WordService.queryAllByKeywordForLike(firstPinyin, firstPinyin.length, (words)=>{
              let keyMap = this.pinyinList.getPinYinKeyMap()
              this.pageWords = convert2SuggestWord(keyMap, words)
            })
          }
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
  loadShowInputContent(): void {
    let showContext = this.getLoadShowInputContent()
    this.previewTextList = showContext.previewTextArray
  }

  getLoadShowInputContent():IPreviewText{
    let showText: Array<PreviewText> = []
    // 旧的已输入字符串
    let oldStr = this.previewTextList.map((value)=> value.str).join()
    Logger.info('旧的输入内容为:' + oldStr)
    let newStr:string = ''
    // 已使用的联想词列表
    this.useWords.forEach((value, index)=>{
      showText.push(new PreviewText(value.showName, true))
    })

    this.inputContent.forEach((value, index) =>
    {
      if (value.fillStr) {
        // 判断是否为手动选择的最后一个符号
        let isEnd = value.isEnd
        let nextStr = ''
        if(isEnd){
          nextStr = value.selectStr == null ?'':value.selectStr + "'"
        }else{
          // 智能选择下一个字符
          if(value.selectStr == null){
            smartSelectChar(oldStr, value)
          }
          nextStr = smartSetNextStrSeg(newStr, value.selectStr == null ?'':value.selectStr)
        }
        // 判断是否为最后一个，最后一个字符不加分词符号
        if(index == this.inputContent.length -1 && nextStr.endsWith("'")){
          nextStr = nextStr.substring(0, nextStr.length-1);
        }
        showText.push(new PreviewText(nextStr, value.locked))
        newStr+=nextStr
      }
    })
    return {previewStr: newStr, previewTextArray: showText}
  }

  /**
   * 输入内容更新时调用事件
   */
  onInputUpdate(){
    // 更新上部的正在输入文本
    let iPreviewText = this.getLoadShowInputContent()
    this.previewTextList = iPreviewText.previewTextArray
    let previewText = iPreviewText.previewStr
    // 更新联想词列表
    getAssociationWord(previewText, this.inputContent, (suggestWords)=>{
      Logger.info(`共查询到${suggestWords.words.length}个联想词`)
      // 更新左侧拼音列表
      this.pinyinList.replaceAllData(suggestWords.pinyin)
      if(this.pinyinList.totalCount() == 0){
        this.showPinYinListPage = false
      }
      this.suggestMode = suggestWords.words.length > 0
      this.suggestWords.replaceAllData(suggestWords.words)
    })
  }

}

/**
 * 预览文本
 */
export class PreviewText{
  id:string;
  // 显示内容
  str:string = ''
  // 是否已锁定
  lock:boolean = false;

  constructor(str: string, lock: boolean) {
    this.str = str
    this.lock = lock
    this.id = util.generateRandomUUID()
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
async function  getAssociationWord(previewText:string,  keyWord:KeyButtonData[], callback:(result:PinyinSuggestResult)=>void){
  if(keyWord.length == 0){
    callback({pinyin: [], words: []})
  }
  let subType = inputMethod.getCurrentInputMethodSubtype()
  let englishMode = subType.id == US_SUB_TYPE_ID
  spellToWord(previewText, keyWord, englishMode, (result)=>{
    callback(result)
  })
}

