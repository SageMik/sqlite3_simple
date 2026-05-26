import { harTasks } from '@ohos/hvigor-ohos-plugin';
import { ohpmPublishPlugin } from 'hvigor-ohpm-publish'

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[ohpmPublishPlugin()]         /* Custom plugin to extend the functionality of Hvigor. */
}
