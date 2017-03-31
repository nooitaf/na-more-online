

fileUploadHandler = function(meta, file) {
	const storageType = RocketChat.settings.get('FileUpload_Storage_Type');

	if (FileUpload[storageType] !== undefined) {
		return new FileUpload[storageType](meta, file);
	}
};
