import EmojiService from '../dao/EmojiService'
import EmojiData from '../data/EmojiData'
import KeyboardController from '../model/KeyboardController'

@Component
@Preview
export struct EmojiPanel{

  @State emojiList:Array<EmojiData.IEmoji> = EmojiData.getEmojiList()

  @State emojiGroup:Array<EmojiData.IEmojiRep> = EmojiData.getEmojiRep()

  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  // 是否展示表情面板
  @Consume showEmojiPanel:boolean;

  build() {
    Row(){
      Tabs({index: this.currentIndex, controller: this.controller}){
        ForEach(this.emojiGroup, (item:EmojiData.IEmojiRep, index:number)=>{
          TabContent(){
            Grid(){
              ForEach(this.emojiList, (item:EmojiData.IEmoji, index)=>{
                GridItem(){
                  Button(){
                    Text(item.character)
                      .fontSize(30)
                  }.backgroundColor(Color.Transparent)
                  .type(ButtonType.Normal)
                  .onClick(()=>{
                    KeyboardController.insertText(item.character)
                    this.showEmojiPanel = false
                  })
                }
              }, (item:EmojiData.IEmoji, index:number)=> item.character)
            }.columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr")
            .rowsGap(6)
          }
          .tabBar(item.name)

        }, (item:EmojiData.IEmojiRep, index:number)=> item.id +'')

      }.barMode(BarMode.Scrollable)
      .onChange((index:number)=>{
        this.currentIndex = index
        // 改变页签内容
        let emojiRep = this.emojiGroup[this.currentIndex]
        let repId = emojiRep.id
        EmojiService.getByRepId(repId, (list)=>{
          this.emojiList = list
        })
      })


    }.width('100%')
    .layoutWeight(1)
    .padding(10)
  }

  aboutToAppear(): void {
    let emojiGroup = this.emojiGroup[0]
    EmojiService.getByRepId(emojiGroup.id, (list)=>{
      this.emojiList = list
    })
  }

}