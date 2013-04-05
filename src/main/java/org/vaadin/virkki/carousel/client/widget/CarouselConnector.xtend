package org.vaadin.virkki.carousel.client.widget

import com.google.gwt.core.client.GWT
import com.vaadin.client.BrowserInfo
import com.vaadin.client.ComponentConnector
import com.vaadin.client.ConnectorHierarchyChangeEvent
import com.vaadin.client.communication.RpcProxy
import com.vaadin.client.communication.StateChangeEvent
import com.vaadin.client.ui.AbstractComponentContainerConnector
import com.vaadin.client.ui.layout.ElementResizeListener
import com.vaadin.shared.communication.ClientRpc
import com.vaadin.shared.communication.ServerRpc
import com.vaadin.shared.ui.Connect
import org.vaadin.virkki.carousel.HorizontalCarousel
import org.vaadin.virkki.carousel.client.widget.gwt.CarouselWidget
import org.vaadin.virkki.carousel.client.widget.gwt.CarouselWidgetListener

@SuppressWarnings("serial")
@Connect(typeof(HorizontalCarousel))
class CarouselConnector extends AbstractComponentContainerConnector {

	override protected createWidget() {
		GWT::create(typeof(CarouselWidget)) => [
			val rpc = RpcProxy::create(typeof(CarouselServerRpc), this)
			(it as CarouselWidget).addListener(rpc)
		]
	}

	val ElementResizeListener listener = [
		widget.carouselWidth = layoutManager.getOuterWidth(element)
	]

	override init() {
		super.init
		layoutManager.addElementResizeListener(widget.element, listener)
		registerRpc(typeof(CarouselClientScrollRpc), [widget.scroll(it)])
		registerRpc(typeof(CarouselClientScrollToRpc),[widget.scrollTo(it)])
	}

	override CarouselState getState() {
		super.getState() as CarouselState
	}

	override CarouselWidget getWidget() {
		super.widget as CarouselWidget
	}

	override onStateChanged(StateChangeEvent stateChangeEvent) {
		super.onStateChanged(stateChangeEvent)
		widget.loadMode = state.loadMode
		widget.widgets = state.connectors.map[if(it != null) (it as ComponentConnector).widget]
		widget.arrowKeysMode = state.arrowKeysMode
		widget.mouseDragEnabled = state.mouseDragEnabled
		widget.touchDragEnabled = state.touchDragEnabled
		widget.mouseWheelEnabled = state.mouseWheelEnabled
		widget.buttonsVisible = state.buttonsVisible
		widget.transitionDuration = state.transitionDuration
		widget.swipeSensitivity = state.swipeSensitivity
		widget.animationFallback = BrowserInfo::get.IE8 || BrowserInfo::get.IE9
	}

	override updateCaption(ComponentConnector connector) {
	}

	override onConnectorHierarchyChange(ConnectorHierarchyChangeEvent connectorHierarchyChangeEvent) {
	}

}

interface CarouselServerRpc extends CarouselWidgetListener, ServerRpc{	
}
interface CarouselClientScrollRpc extends ClientRpc{
	def void scroll(int change)
}
interface CarouselClientScrollToRpc extends ClientRpc{
	def void scrollTo(int componentIndex)
}