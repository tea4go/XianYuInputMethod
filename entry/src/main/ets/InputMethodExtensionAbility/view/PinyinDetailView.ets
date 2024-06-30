import { WordDataSource } from '../dao/DataSouce';
import { SuggestionWord } from './SmartSuggestionBar';
import { util } from '@kit.ArkTS';
import {
  extractChineseCharacters,
  getDictInfo, getSpellDictJian, PinyinSuggestGroup } from '../../cncharInput/cnchar/util/SpellToWordUtil';
import { getPinyinDetailRightButtonGroupData, KeyButtonData } from '../data/KeyButtonDataManager';
import { switchChineseOrEnglish } from '../util/SwitchUtil';
import { inputMethod } from '@kit.IMEKit';
import keyboardController from '../model/KeyboardController';
import { MockSetup } from '@ohos/hamock';

@Component
@Preview
// @Entry
export struct  PinyinDetailView{

  @Consume words: WordDataSource;
  // @State wordsDataSource: Array<PinyinSuggestGroup> = [];
  // @State wordsDataSource: WordDataSource = this.getTestData();

  // 当前的拼音index
  @State currentWordsIndex:number = 0
  @State rightKeyData:KeyButtonData[] = getPinyinDetailRightButtonGroupData()

  // @State pinyinList:Array<string> = ['ai', 'bi', 'ci', 'ch', "ci", 'a', 'b', 'c']

  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage:boolean;
  //
  @Consume inputContent:Array<KeyButtonData>
  // 已使用的按键
  @Consume useWords:Array<SuggestionWord>


  @MockSetup
  mock(){
    // this.wordsDataSource = this.getTestData();
    // this.currentWords = this.wordsDataSource[0].words
  }


  getTestData():Array<PinyinSuggestGroup>{
    let pinyinGroup:Array<PinyinSuggestGroup> = []
    let pinyinList = ['ai', 'bi', 'ci', 'ch']
    let spellDictJian = getSpellDictJian()
    let initialData = getDictInfo();
    let index:number = 0
    pinyinList.forEach((value)=>{
      // 检查是否为声母
      if (initialData.initial.includes(value)) {
        const hanzhiList:string = '艾9哎1哀1诶1唉9唉6埃1挨7挨6爱4砹4捱2皑2隘4嗌9嗳9嗳8嗳6嫒4矮3碍4暧4瑷4蔼3锿1噫9癌2霭3娭6'
        if (hanzhiList && hanzhiList.length > 0) {
          let chineseCharacters:Array<SuggestionWord> = extractChineseCharacters(value, hanzhiList, [])
          //
          chineseCharacters.forEach((item)=>{
            item.id = index + ''
            index+= 1
          })

          let group:PinyinSuggestGroup = {pinyin: value, words: chineseCharacters}
          pinyinGroup.push(group)
        }
      }
    })
    return pinyinGroup;
  }


  build() {
    Row(){
      // 左侧菜单栏
      Row(){
        List({space: 1}){
          LazyForEach(this.words, (item:PinyinSuggestGroup, index:number)=>{
            ListItem(){
              Button(){
                Text(item.pinyin)
                  .textAlign(TextAlign.Center)
                  .height(40)
                  .width('100%')
              }.type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .backgroundColor(Color.White)
              .width('100%')
              .onClick(()=>{
                this.currentWordsIndex = index
              })
            }
          }, (item:string)=> item)
        }.width('100%').height('100%').alignListItem(ListItemAlign.Center)
      }.width('13%').height('100%').backgroundColor(Color.White)
      Row()
        .backgroundColor('#f1f1f1')
        .opacity(0.5)
        .width(0.5).height('100%')

      // 右侧具体拼音栏
      Row(){
        Grid(){
          ForEach(this.words.getSuggestionList(this.currentWordsIndex), (item:SuggestionWord)=>{
            GridItem(){
              Button(){
                Text(item.showName)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height(40)
              }.backgroundColor(Color.White)
              .layoutWeight(1)
              .borderColor('#f1f1f1')
              .borderWidth({bottom: 0.01})
              .type(ButtonType.Normal)
              .onClick(()=>{
                this.onSuggestWordClick(item)
              })
            }
          }, (item:SuggestionWord)=>item.id)
        }.columnsTemplate('1fr 1fr 1fr 1fr')
        //.friction(0.6)
        .width('100%')
        .height('100%')
        // .rowsGap(0.2)
      }.layoutWeight(1).height('100%')
      .borderRadius(5)
      .backgroundColor(Color.Transparent)
      .margin({right: 5})

      // 右侧按钮栏
      Row(){
        Column({space: 6}){
          ForEach(this.rightKeyData, (item: KeyButtonData, index: number) => {
            if(item.key == 'del'){
              Button() {
                Image($r('app.media.del')).width(40).height(40)
                  .padding(5)
              }.backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .width('100%').layoutWeight(1)
              .onClick(()=>{
                this.onButtonClick(item)
              })
            }else if (item.key == 'zero'){
              Button() {
                Column() {
                  Text(item.name).fontSize(18)
                }
              }.backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .borderRadius(5)
              .width('100%').layoutWeight(1)
              .onClick(()=>{
                this.onButtonClick(item)
              })
            }else{
              Button() {
                Column() {
                  if(item.key == 'allOrWord'){
                    Text(){
                      Span('全').fontSize(14)
                      Span('/字').fontSize(12).fontColor(Color.Grey)
                    }
                  }else if(item.key == 'pinyinOrWuBi'){
                    Text(){
                      Span('拼').fontSize(14)
                      Span('/笔').fontSize(12).fontColor(Color.Grey)
                    }
                  }else{
                    Text(item.name).fontSize(14)
                  }

                }
              }.backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .borderRadius(5)
              .width('100%').layoutWeight(1)
              .onClick(()=>{
                this.onButtonClick(item)
              })
            }


          }, (item: KeyButtonData, index: number) => item.key)
        }.width('100%').height('100%').backgroundColor('#eff0f4')
        .borderRadius(5)
        .justifyContent(FlexAlign.SpaceAround)
      }.width('15%').height('100%').backgroundColor(Color.Transparent)

    }.width('100%')
    .layoutWeight(1)
    .backgroundColor(Color.Transparent)
    .padding({left: 16, right: 16, top: 2, bottom: 4})
  }


  /**
   * 候选词点击事件
   * @param word
   */
  onSuggestWordClick(word: SuggestionWord){
      // 完成拼写，更新按键状态
      this.useWords.push(word)
  }

  /**
   * 按钮点击事件
   * @param item
   */
  onButtonClick(item:KeyButtonData){
    if(item.key == 'chineseOrEnglish'){
      switchChineseOrEnglish()
    }else if(item.key == 'back'){
      this.showPinYinListPage = false;
    }else if(item.key == 'reInput'){
     // let length = this.getShowInputContent().length
     // keyboardController.clearText(length)
    }else if(item.key == 'del'){
      keyboardController.deleteForward(1);
      this.inputContent.pop()
    }else{
    }
  }

  /**
   * 点击按键之后的事件
   * @param inputData
   */
  pushToContent(inputData:KeyButtonData){
    this.inputContent.push(inputData)
    if(inputData.fillStr){
      // 设置输入框里面的预上屏幕文本
      // let previewText = this.getShowInputContent()
      // keyboardController.setPreviewText(previewText)
    }
  }
}


