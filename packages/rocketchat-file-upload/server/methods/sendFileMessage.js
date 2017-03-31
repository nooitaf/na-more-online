Meteor.methods({
	'sendFileMessage'(roomId, store, file, msgData = {}) {
		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'sendFileMessage' });
		}

		const room = Meteor.call('canAccessRoom', roomId, Meteor.userId());

		if (!room) {
			return false;
		}

		check(msgData, {
			avatar: Match.Optional(String),
			emoji: Match.Optional(String),
			alias: Match.Optional(String),
			groupable: Match.Optional(Boolean),
			msg: Match.Optional(String)
		});

		RocketChat.models.Uploads.updateFileComplete(file._id, Meteor.userId(), _.omit(file, '_id'));

		const fileUrl = '/file-upload/' + file._id + '/' + file.name;

		const attachment = {
			title: `${TAPi18n.__('Attachment_File_Uploaded')}: ${file.name}`,
			description: file.description,
			title_link: fileUrl,
			title_link_download: true
		};

		if (/^image\/.+/.test(file.type)) {
			attachment.image_url = fileUrl;
			attachment.image_type = file.type;
			attachment.image_size = file.size;
			if (file.identify && file.identify.size) {
				attachment.image_dimensions = file.identify.size;
			}
		} else if (/^audio\/.+/.test(file.type)) {
			attachment.audio_url = fileUrl;
			attachment.audio_type = file.type;
			attachment.audio_size = file.size;
		} else if (/^video\/.+/.test(file.type)) {
			attachment.video_url = fileUrl;
			attachment.video_type = file.type;
			attachment.video_size = file.size;
		}

		const msg = Object.assign({
			_id: Random.id(),
			rid: roomId,
			msg: '',
			file: {
				_id: file._id
			},
			groupable: false,
			attachments: [attachment]
		}, msgData);

		return Meteor.call('sendMessage', msg);
	}
});

Meteor.methods({
	'setRoomImage'(meta, file) {
		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'sendFileMessage' });
		}

	//	const room = Meteor.call('canAccessRoom', roomId, Meteor.userId());
    //
	//	if (!room) {
	//		return false;
	//}


		if(meta.flag == 'i') {
			RocketChat.models.Rooms.setImgById(meta.rid, file._id, file.name);
		}


		if(meta.flag == 'k') {
			RocketChat.models.Catalogs.setCatalogImg(meta.rid, file._id, file.name);

		}


		if(meta.flag == 'o') {

			RocketChat.models.Orgs.setOrgImg(meta.rid, file._id, file.name);
		}

		if(meta.flag == 'og') {

			RocketChat.models.Orgs.setOrgGallery(meta.rid, file._id, file.name);
		}

		if(meta.flag == 'si') {
			return true
		}

		if(meta.flag == 'u') {
			RocketChat.models.Users.setGalleryImg(meta.rid, file._id, file.name);
		}


	}

});