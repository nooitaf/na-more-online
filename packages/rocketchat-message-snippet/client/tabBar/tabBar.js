Meteor.startup(function() {
	Tracker.autorun(function() {
		if (RocketChat.settings.get('Message_AllowSnippeting')) {
			RocketChat.TabBar.addButton({
				groups: ['channel', 'group', 'direct'],
				id: 'snippeted-messages',
				i18nTitle: 'Snippeted_Messages',
				icon: 'icon-code',
				template: 'snippetedMessages',
				order: 20
			});
		} else {
			RocketChat.TabBar.removeButton('snippeted-messages');
		}
	});
});

//nearby button
Meteor.startup(function() {
	Tracker.autorun(function() {
			RocketChat.TabBar.addButton({
				groups: ['nearby'],
				id: 'settings',
				i18nTitle: 'Settings',
				icon: 'icon-cog',
				template: 'nearbySettings',
				order: 20
			});
	});
});
