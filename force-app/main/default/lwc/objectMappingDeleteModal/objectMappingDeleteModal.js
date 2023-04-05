import LightningModal from "lightning/modal";
import {api} from "lwc";

export default class ObjectMappingDeleteModal extends LightningModal {
    @api content;
    handleOkay() {
        this.close('ok');
    }
    handleCancel() {
        this.close();
    }
}