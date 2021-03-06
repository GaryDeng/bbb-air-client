package org.bigbluebutton.view.ui
{
	import mx.core.UIComponent;
	
	import org.bigbluebutton.command.NavigateToSignal;
	import org.bigbluebutton.model.IUserUISession;
	import org.bigbluebutton.view.navigation.pages.PagesENUM;

	import org.bigbluebutton.view.navigation.pages.TransitionAnimationENUM;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class NavigationButtonMediator extends Mediator
	{
		[Inject]
		public var userSession: IUserUISession;
		
		[Inject]
		public var navigateToPageSignal: NavigateToSignal;
				
		[Inject]
		public var view: INavigationButton;
		
		
		override public function initialize():void
		{
			view.navigationSignal.add(navigate);
			
			userSession.pageChangedSignal.add(update);
			
			update(userSession.currentPage);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			view.dispose();
			
			view.navigationSignal.remove(navigate);
			
			view = null;			
			
			userSession.pageChangedSignal.remove(update);
		}
		
		/**
		 * Navigate to the page specified on parameter
		 */
		private function navigate(): void
		{
			navigateToPageSignal.dispatch(view.navigateTo[0], view.pageDetails, view.transitionAnimation);
		}
		
		/**
		 * Update the view when there is a change in the model
		 */ 
		private function update(page:String, action:Boolean = false, animation:int = TransitionAnimationENUM.APPEAR):void
		{
			if(view.navigateTo.indexOf(page) == 0)
			{
				if(containState(view, "selected")) 
				{
					view.currentState = "selected";
				}
			}
			else if(view.navigateTo.indexOf(page)>0)
			{				
				if(containState(view, "unselected"))
				{
					view.currentState = "selected";																	
				}
				else
				{
					view.currentState = "unselected";
				}
			}
		}
		
		private function containState(view:INavigationButton, stateName:String):Boolean
		{
			var states:Array = view.states;
			for (var i:int = 0; i < states.length; i++)
			{
				if (states[i].name == stateName)
				{
					return true;
				}
			}
			return false;			
		}
	}
}