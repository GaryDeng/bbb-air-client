package org.mconf.mobile.core
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import mx.utils.ObjectUtil;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class JoinService implements IJoinService
	{
		private var _urlRequest:URLRequest = null;
		private var _successfullyJoinedMeetingSignal:Signal = new Signal();
		private var _unsuccessfullyJoinedMeetingSignal:Signal = new Signal();
		
		public function JoinService() {
		}
		
		public function get successfullyJoinedMeetingSignal():ISignal {
			return _successfullyJoinedMeetingSignal;
		}

		public function get unsuccessfullyJoinedMeetingSignal():ISignal {
			return _unsuccessfullyJoinedMeetingSignal;
		}
		
		public function load(joinUrl:String):void {
			_urlRequest = new URLRequest( joinUrl );
			_urlRequest.method = URLRequestMethod.GET;
			_urlRequest.manageCookies = true;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, joinHandleComplete );
			urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, joinIOErrorHandler );
			urlLoader.load( _urlRequest );
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void {
			// doing nothing here
		}
		
		private function joinHandleComplete(e:Event):void {
			enter("http://test-install.blindsidenetworks.com/bigbluebutton/api/enter");
		}
		
		private function joinIOErrorHandler(e:IOErrorEvent):void {
			trace("Something went wrong fetching the join URL");
			trace(ObjectUtil.toString(e));
		}

		public function enter(enterUrl:String):void {
			// the flash app will call enter directly
			if (!_urlRequest) {
				_urlRequest = new URLRequest();
				_urlRequest.method = URLRequestMethod.GET;
			}
			_urlRequest.url = enterUrl;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, enterHandleComplete );
			urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, enterIOErrorHandler );
			urlLoader.load( _urlRequest );
		}
		
		private function enterHandleComplete(e:Event):void {
			trace("JoinService::enterHandleComplete()");
			var xml:XML = new XML(e.target.data);
			
			var returncode:String = xml.returncode;
			if (returncode == 'FAILED') {
				trace("Join FAILED");
				trace(ObjectUtil.toString(e));
				
				unsuccessfullyJoinedMeetingSignal.dispatch("Add some reason here!");
			} else if (returncode == 'SUCCESS') {
				trace("Join SUCCESS");
				var user:Object = {
						username:xml.fullname, 
						conference:xml.conference, 
						conferenceName:xml.confname,
						externMeetingID:xml.externMeetingID,
						meetingID:xml.meetingID, 
						externUserID:xml.externUserID, 
						internalUserId:xml.internalUserID,
						role:xml.role, 
						room:xml.room, 
						authToken:xml.room, 
						record:xml.record, 
						webvoiceconf:xml.webvoiceconf, 
						dialnumber:xml.dialnumber,
						voicebridge:xml.voicebridge, 
						mode:xml.mode, 
						welcome:xml.welcome, 
						logoutUrl:xml.logoutUrl, 
						defaultLayout:xml.defaultLayout, 
						avatarURL:xml.avatarURL };
				user.customdata = new Object();
				if(xml.customdata)
				{
					for each(var cdnode:XML in xml.customdata.elements()){
						trace("checking user customdata: "+cdnode.name() + " = " + cdnode);
						user.customdata[cdnode.name()] = cdnode.toString();
					}
				}
				trace("Dispatching successfullyJoinedMeetingSignal");
				successfullyJoinedMeetingSignal.dispatch(user);
			}
		}
		
		private function enterIOErrorHandler(e:IOErrorEvent):void {
			trace("Something went wrong fetching the enter URL");
			trace(ObjectUtil.toString(e));
		}
	
	}
}