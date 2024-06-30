/**
 * 切换中英文输入法
 */
import { inputMethod } from '@kit.IMEKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CN_SUB_TYPE_ID, US_SUB_TYPE_ID } from '../constant/InputMethConstant';

export function switchChineseOrEnglish() {
  try {
    let extra: Record<string, string> = {}
    const currentSubtype = inputMethod.getCurrentInputMethodSubtype();
    let isCnInput = null == currentSubtype || currentSubtype.id == CN_SUB_TYPE_ID
    inputMethod.switchCurrentInputMethodSubtype({
      id: isCnInput ? US_SUB_TYPE_ID : CN_SUB_TYPE_ID,
      mode: "upper",
      locale: isCnInput ? "en-US" : "zh-CN",
      name: 'com.lonwan.input.method',
      language: isCnInput ? "en-US" : "zh-CN"
    }, (err: BusinessError, result: boolean) => {
      if (err) {
        console.error(`Failed to switchCurrentInputMethodSubtype: ${JSON.stringify(err)}`);
        return;
      }
      if (result) {
        console.log('Succeeded in switching currentInputMethodSubtype.');
      } else {
        console.error('Failed to switchCurrentInputMethodSubtype');
      }
    });
  } catch(err) {
    console.error(`Failed to switchCurrentInputMethodSubtype: ${JSON.stringify(err)}`);
  }
}