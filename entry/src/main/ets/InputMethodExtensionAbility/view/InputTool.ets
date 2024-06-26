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