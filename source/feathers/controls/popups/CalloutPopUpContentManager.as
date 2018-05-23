/*
Feathers
Copyright 2012-2018 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.popups
{
	import feathers.controls.Callout;
	import feathers.core.PopUpManager;
	import feathers.layout.RelativePosition;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;

	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;

	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.utils.Pool;

	/**
	 * Dispatched when the pop-up content opens.
	 *
	 * <p>The properties of the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Value</th></tr>
	 * <tr><td><code>bubbles</code></td><td>false</td></tr>
	 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
	 *   event listener that handles the event. For example, if you use
	 *   <code>myButton.addEventListener()</code> to register an event listener,
	 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
	 * <tr><td><code>data</code></td><td>null</td></tr>
	 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
	 *   it is not always the Object listening for the event. Use the
	 *   <code>currentTarget</code> property to always access the Object
	 *   listening for the event.</td></tr>
	 * </table>
	 *
	 * @eventType starling.events.Event.OPEN
	 */
	[Event(name="open",type="starling.events.Event")]

	/**
	 * Dispatched when the pop-up content closes.
	 *
	 * <p>The properties of the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Value</th></tr>
	 * <tr><td><code>bubbles</code></td><td>false</td></tr>
	 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
	 *   event listener that handles the event. For example, if you use
	 *   <code>myButton.addEventListener()</code> to register an event listener,
	 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
	 * <tr><td><code>data</code></td><td>null</td></tr>
	 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
	 *   it is not always the Object listening for the event. Use the
	 *   <code>currentTarget</code> property to always access the Object
	 *   listening for the event.</td></tr>
	 * </table>
	 *
	 * @eventType starling.events.Event.CLOSE
	 */
	[Event(name="close",type="starling.events.Event")]

	/**
	 * Displays pop-up content (such as the List in a PickerList) in a Callout.
	 *
	 * @see feathers.controls.PickerList
	 * @see feathers.controls.Callout
	 *
	 * @productversion Feathers 1.0.0
	 */
	public class CalloutPopUpContentManager extends EventDispatcher implements IPopUpContentManager
	{
		/**
		 * Constructor.
		 */
		public function CalloutPopUpContentManager()
		{
			super();
		}

		/**
		 * The factory used to create the <code>Callout</code> instance. If
		 * <code>null</code>, <code>Callout.calloutFactory()</code> will be used.
		 *
		 * <p>Note: If you change this value while a callout is open, the new
		 * value will not go into effect until the callout is closed and a new
		 * callout is opened.</p>
		 *
		 * @see feathers.controls.Callout#calloutFactory
		 *
		 * @default null
		 */
		public var calloutFactory:Function;

		/**
		 * The direction of the callout.
		 *
		 * <p>Note: If you change this value while a callout is open, the new
		 * value will not go into effect until the callout is closed and a new
		 * callout is opened.</p>
		 *
		 * <p>In the following example, the callout direction is restricted to down:</p>
		 *
		 * <listing version="3.0">
		 * manager.direction = Callout.DIRECTION_DOWN;</listing>
		 *
		 * @see feathers.controls.Callout#DIRECTION_ANY
		 * @see feathers.controls.Callout#DIRECTION_UP
		 * @see feathers.controls.Callout#DIRECTION_DOWN
		 * @see feathers.controls.Callout#DIRECTION_LEFT
		 * @see feathers.controls.Callout#DIRECTION_RIGHT
		 *
		 * @default Callout.DIRECTION_ANY
		 */
		public var supportedPositions:Vector.<String> = Callout.DEFAULT_POSITIONS;

		/**
		 * @private
		 */
		protected var _direction:String = null;

		[Deprecated(replacement="supportedPositions",since="3.2.0")]
		/**
		 * @private
		 * DEPRECATED: Replaced by the <code>supportedPositions</code> property.
		 *
		 * <p><strong>DEPRECATION WARNING:</strong> This property is deprecated
		 * starting with Feathers 3.0. It will be removed in a future version of
		 * Feathers according to the standard
		 * <a target="_top" href="../../../help/deprecation-policy.html">Feathers deprecation policy</a>.</p>
		 */
		public function get direction():String
		{
			return this._direction;
		}

		/**
		 * @private
		 */
		public function set supportedDirections(value:String):void
		{
			var positions:Vector.<String> = null;
			if(value === "any")
			{
				positions = new <String>[RelativePosition.BOTTOM, RelativePosition.TOP, RelativePosition.RIGHT, RelativePosition.LEFT];
			}
			else if(value === "horizontal")
			{
				positions = new <String>[RelativePosition.RIGHT, RelativePosition.LEFT];
			}
			else if(value === "vertical")
			{
				positions = new <String>[RelativePosition.BOTTOM, RelativePosition.TOP];
			}
			else if(value === "up")
			{
				positions = new <String>[RelativePosition.TOP];
			}
			else if(value === "down")
			{
				positions = new <String>[RelativePosition.BOTTOM];
			}
			else if(value === "right")
			{
				positions = new <String>[RelativePosition.RIGHT];
			}
			else if(value === "left")
			{
				positions = new <String>[RelativePosition.LEFT];
			}
			this._direction = value;
			this.supportedPositions = positions;
		}

		/**
		 * Determines if the callout will be modal or not.
		 *
		 * <p>Note: If you change this value while a callout is open, the new
		 * value will not go into effect until the callout is closed and a new
		 * callout is opened.</p>
		 *
		 * <p>In the following example, the callout is not modal:</p>
		 *
		 * <listing version="3.0">
		 * manager.isModal = false;</listing>
		 *
		 * @default true
		 */
		public var isModal:Boolean = true;

		/**
		 * @private
		 */
		protected var _overlayFactory:Function = null;

		/**
		 * If <code>isModal</code> is <code>true</code>, this function may be
		 * used to customize the modal overlay displayed by the pop-up manager.
		 * If the value of <code>overlayFactory</code> is <code>null</code>, the
		 * pop-up manager's default overlay factory will be used instead.
		 *
		 * <p>This function is expected to have the following signature:</p>
		 * <pre>function():DisplayObject</pre>
		 *
		 * <p>In the following example, the overlay is customized:</p>
		 *
		 * <listing version="3.0">
		 * manager.isModal = true;
		 * manager.overlayFactory = function():DisplayObject
		 * {
		 *     var quad:Quad = new Quad(1, 1, 0xff00ff);
		 *     quad.alpha = 0;
		 *     return quad;
		 * };</listing>
		 *
		 * @default null
		 *
		 * @see feathers.core.PopUpManager#overlayFactory
		 */
		public function get overlayFactory():Function
		{
			return this._overlayFactory;
		}

		/**
		 * @private
		 */
		public function set overlayFactory(value:Function):void
		{
			this._overlayFactory = value;
		}

		/**
		 * @private
		 */
		protected var content:DisplayObject;

		/**
		 * @private
		 */
		protected var callout:Callout;

		/**
		 * @inheritDoc
		 */
		public function get isOpen():Boolean
		{
			return this.content !== null;
		}

		/**
		 * @inheritDoc
		 */
		public function open(content:DisplayObject, source:DisplayObject):void
		{
			if(this.isOpen)
			{
				throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
			}

			var scaledCalloutFactory:Function = this.calloutFactory;
			//make sure the content is scaled the same as the source
			var matrix:Matrix = Pool.getMatrix();
			source.getTransformationMatrix(PopUpManager.root, matrix);
			var contentScaleX:Number = matrixToScaleX(matrix)
			var contentScaleY:Number = matrixToScaleY(matrix);
			Pool.putMatrix(matrix);
			if(contentScaleX != 1 || contentScaleY != 1)
			{
				var originalCalloutFactory:Function = this.calloutFactory;
				if(originalCalloutFactory === null)
				{
					originalCalloutFactory = Callout.calloutFactory;
				}
				scaledCalloutFactory = function():Callout
				{
					var callout:Callout = originalCalloutFactory();
					callout.scaleX = contentScaleX;
					callout.scaleY = contentScaleY;
					return callout;
				}
			}

			this.content = content;
			this.callout = Callout.show(content, source, this.supportedPositions, this.isModal, scaledCalloutFactory, this._overlayFactory);
			this.callout.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
			this.dispatchEventWith(Event.OPEN);
		}

		/**
		 * @inheritDoc
		 */
		public function close():void
		{
			if(!this.isOpen)
			{
				return;
			}
			this.callout.close();
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			this.close();
		}

		/**
		 * @private
		 */
		protected function cleanup():void
		{
			this.content = null;
			this.callout.content = null;
			this.callout.removeEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
			this.callout = null;
		}

		/**
		 * @private
		 */
		protected function callout_removedFromStageHandler(event:Event):void
		{
			this.cleanup();
			this.dispatchEventWith(Event.CLOSE);
		}
	}
}
