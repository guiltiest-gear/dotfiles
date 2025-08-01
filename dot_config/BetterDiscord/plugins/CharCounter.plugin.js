/**
 * @name CharCounter
 * @author DevilBro
 * @authorId 278543574059057154
 * @version 1.6.9
 * @description Adds a Character Counter to most Inputs
 * @invite Jx3TjNS
 * @donate https://www.paypal.me/MircoWittrien
 * @patreon https://www.patreon.com/MircoWittrien
 * @website https://mwittrien.github.io/
 * @source https://github.com/mwittrien/BetterDiscordAddons/tree/master/Plugins/CharCounter/
 * @updateUrl https://mwittrien.github.io/BetterDiscordAddons/Plugins/CharCounter/CharCounter.plugin.js
 */

module.exports = (_ => {
	const changeLog = {
		
	};

	return !window.BDFDB_Global || (!window.BDFDB_Global.loaded && !window.BDFDB_Global.started) ? class {
		constructor (meta) {for (let key in meta) this[key] = meta[key];}
		getName () {return this.name;}
		getAuthor () {return this.author;}
		getVersion () {return this.version;}
		getDescription () {return `The Library Plugin needed for ${this.name} is missing. Open the Plugin Settings to download it. \n\n${this.description}`;}
		
		downloadLibrary () {
			BdApi.Net.fetch("https://mwittrien.github.io/BetterDiscordAddons/Library/0BDFDB.plugin.js").then(r => {
				if (!r || r.status != 200) throw new Error();
				else return r.text();
			}).then(b => {
				if (!b) throw new Error();
				else return require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0BDFDB.plugin.js"), b, _ => BdApi.UI.showToast("Finished downloading BDFDB Library", {type: "success"}));
			}).catch(error => {
				BdApi.UI.alert("Error", "Could not download BDFDB Library Plugin. Try again later or download it manually from GitHub: https://mwittrien.github.io/downloader/?library");
			});
		}
		
		load () {
			if (!window.BDFDB_Global || !Array.isArray(window.BDFDB_Global.pluginQueue)) window.BDFDB_Global = Object.assign({}, window.BDFDB_Global, {pluginQueue: []});
			if (!window.BDFDB_Global.downloadModal) {
				window.BDFDB_Global.downloadModal = true;
				BdApi.UI.showConfirmationModal("Library Missing", `The Library Plugin needed for ${this.name} is missing. Please click "Download Now" to install it.`, {
					confirmText: "Download Now",
					cancelText: "Cancel",
					onCancel: _ => {delete window.BDFDB_Global.downloadModal;},
					onConfirm: _ => {
						delete window.BDFDB_Global.downloadModal;
						this.downloadLibrary();
					}
				});
			}
			if (!window.BDFDB_Global.pluginQueue.includes(this.name)) window.BDFDB_Global.pluginQueue.push(this.name);
		}
		start () {this.load();}
		stop () {}
		getSettingsPanel () {
			let template = document.createElement("template");
			template.innerHTML = `<div style="color: var(--header-primary); font-size: 16px; font-weight: 300; white-space: pre; line-height: 22px;">The Library Plugin needed for ${this.name} is missing.\nPlease click <a style="font-weight: 500;">Download Now</a> to install it.</div>`;
			template.content.firstElementChild.querySelector("a").addEventListener("click", this.downloadLibrary);
			return template.content.firstElementChild;
		}
	} : (([Plugin, BDFDB]) => {
		const maxLengths = {
			customstatus: 128,
			popoutnote: 256,
			profilenote: 256
		};
		const typeMap = {
			normal: "chat",
			form: "upload",
			sidebar: "chat",
			thread_creation: "threadcreation",
			user_profile: "userprofile"
		};
		const nativeCounters = ["profile_bio_input"];
	
		return class CharCounter extends Plugin {
			onLoad () {
				this.modulePatches = {
					after: [
						"ChannelTextAreaContainer",
						"CustomStatusModal",
						"Note"
					]
				};
				
				this.defaults = {
					sliders: {
						showPercentage:			{value: 0,				description: "Only shows Counter after certain % of Max Length is reached"}
					}
				};
				
				this.css = `
					${BDFDB.dotCN._charcountercounteradded} {
						position: relative !important;
						width: 100%;
					}
					${BDFDB.dotCN._charcountercounter} {
						display: block;
						position: absolute;
						font-size: 15px;
						z-index: 10;
						pointer-events: none;
					}
					${BDFDB.dotCNS.textareaaccessorybarright + BDFDB.dotCN._charcountercounter} {
						position: static;
						margin-left: 8px;
					}
					${BDFDB.dotCN._charcounterchatcounter} {
						right: 0;
						bottom: 0.3em;
					}
					${BDFDB.dotCN._charcountereditcounter} {
						right: 0;
						bottom: -1.3em;
					}
					${BDFDB.dotCN._charcounterthreadcreationcounter} {
						right: 16px;
						bottom: 0.3em;
					}
					${BDFDB.dotCN._charcounteruserprofilecounter} {
						right: 0;
						bottom: -1.3em;
						font-size: 12px;
					}
					${BDFDB.dotCN._charcountercustomstatuscounter} {
						right: 0 !important;
						top: -1.5em;
					}
					${BDFDB.dotCN._charcounterpopoutnotecounter} {
						right: 3px !important;
						bottom: -8px !important;
						font-size: 10px !important;
					}
					${BDFDB.dotCN._charcounterprofilenotecounter} {
						right: 0 !important;
						bottom: -10px !important;
						font-size: 12px !important;
					}
					${BDFDB.dotCN.usernotetextarea}:not(:focus) ~ ${BDFDB.dotCN._charcountercounter},
					${BDFDB.dotCNS.userpopoutouter + BDFDB.dotCN.textareawrapall}:not(:focus-within) ~ ${BDFDB.dotCN._charcountercounter} {
						display: none;
					}
				`;
			}
			
			onStart () {
				BDFDB.PatchUtils.forceAllUpdates(this);
			}
			
			onStop () {
				BDFDB.PatchUtils.forceAllUpdates(this);
			}

			getSettingsPanel (collapseStates = {}) {
				let settingsPanel;
				return settingsPanel = BDFDB.PluginUtils.createSettingsPanel(this, {
					collapseStates: collapseStates,
					children: _ => {
						let settingsItems = [];
						
						for (let key in this.defaults.sliders) settingsItems.push(BDFDB.ReactUtils.createElement(BDFDB.LibraryComponents.SettingsSaveItem, {
							type: "Slider",
							plugin: this,
							keys: ["sliders", key],
							basis: "30%",
							label: this.defaults.sliders[key].description,
							value: this.settings.sliders[key]
						}));
						
						return settingsItems;
					}
				});
			}

			onSettingsClosed () {
				if (this.SettingsUpdated) {
					delete this.SettingsUpdated;
					BDFDB.PatchUtils.forceAllUpdates(this);
				}
			}

			processChannelTextAreaContainer (e) {
				let editorContainer = BDFDB.ReactUtils.findChild(e.returnvalue, {name: "ChannelTextAreaEditor"});
				if (editorContainer && editorContainer.props.type && !editorContainer.props.disabled) {
					if (!BDFDB.ArrayUtils.is(e.returnvalue.props.children)) e.returnvalue.props.children = [e.returnvalue.props.children];
					this.injectCounter(e.returnvalue, e.returnvalue.props.children, editorContainer.props.type.analyticsName || editorContainer.props.type, BDFDB.dotCN.textarea);
				}
			}

			processNote (e) {
				let [children, index] = BDFDB.ReactUtils.findParent(e.returnvalue, {filter: n => n && n.props && n.props.autoCorrect != undefined});
				if (index > -1) this.injectCounter(e.returnvalue, children, e.instance.props.className && e.instance.props.className.indexOf(BDFDB.disCN.usernotepopout) > -1 ? "popoutnote" : "profilenote", "textarea");
			}

			processNicknameSection (e) {
				e.returnvalue.props.children = BDFDB.ReactUtils.createElement("div", {
					className: BDFDB.disCN._charcountercounteradded,
					children: [
						e.returnvalue.props.children,
						BDFDB.ReactUtils.createElement("div", {
							className: BDFDB.DOMUtils.formatClassName(BDFDB.disCN.charcounter, BDFDB.disCN._charcountercounter, BDFDB.disCN._charcounternickcounter),
							children: `${(e.instance.props.pendingNick || "").length}/${maxLengths.nick}`
						})
					].flat(10)
				});
			}

			processCustomStatusModal (e) {
				let formItem = BDFDB.ReactUtils.findChild(e.returnvalue, {props: [["className", BDFDB.disCN.emojiinputcontainer]]});
				if (formItem) this.injectCounter(formItem, formItem.props.children, "customstatus", BDFDB.dotCN.input);
			}
			
			injectCounter (parent, children, type, refClass, parsing) {
				if (!children || nativeCounters.indexOf(type) > -1) return;
				if (parent.props.className) parent.props.className = BDFDB.DOMUtils.formatClassName(parent.props.className, BDFDB.disCN._charcountercounteradded);
				else parent.props.children = BDFDB.ReactUtils.createElement("div", {
					className: BDFDB.disCN._charcountercounteradded,
					children: parent.props.children
				});
				children.push(BDFDB.ReactUtils.createElement(BDFDB.LibraryComponents.CharCounter, {
					className: BDFDB.DOMUtils.formatClassName(BDFDB.disCN._charcountercounter, type && BDFDB.DiscordClasses[`_charcounter${typeMap[type] || type}counter`] && BDFDB.disCN[`_charcounter${typeMap[type] || type}counter`]),
					refClass: refClass,
					parsing: parsing,
					max: maxLengths[type] || (BDFDB.LibraryModules.NitroUtils.canUseIncreasedMessageLength(BDFDB.LibraryStores.UserStore.getCurrentUser()) ? BDFDB.DiscordConstants.MAX_MESSAGE_LENGTH_PREMIUM : BDFDB.DiscordConstants.MAX_MESSAGE_LENGTH),
					showPercentage: this.settings.sliders.showPercentage,
					style: {visibility: "hidden"},
					onChange: instance => {
						let node = BDFDB.ReactUtils.findDOMNode(instance);
						node && node.style.removeProperty("visibility");
						let form = node && BDFDB.DOMUtils.getParent(BDFDB.dotCN.chatform, node);
						if (form) {
							let widthDifference = BDFDB.DOMUtils.getWidth(form.firstElementChild) - BDFDB.DOMUtils.getWidth(node.parentElement);
							if (widthDifference > 0) node.style.setProperty("right", `-${widthDifference}px`);
							let typing = form.querySelector(BDFDB.dotCN.typing);
							if (typing) typing.style.setProperty("margin-right", `${BDFDB.DOMUtils.getWidth(node) + 10}px`);
						}
					}
				}));
			}
		};
	})(window.BDFDB_Global.PluginUtils.buildPlugin(changeLog));
})();
