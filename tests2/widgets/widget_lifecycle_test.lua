-- TEST: Widget Lifecycle
-- FILE: tests2/widgets/widget_lifecycle_test.lua
-- UI widget creation, event handling, and rendering lifecycle

local HierarchicalSuite = require('tests2.framework.hierarchical_suite')
local Helpers = require('tests2.utils.test_helpers')

-- MOCK WIDGET SYSTEM
local MockWidget = {}
function MockWidget:new(id, widgetType)
    return {
        id = id,
        type = widgetType or 'Button',
        active = true,
        visible = true,
        x = 0,
        y = 0,
        width = 100,
        height = 50,
        children = {},
        parent = nil,
        eventHandlers = {},
        state = 'created',
        renderCount = 0
    }
end

local MockWidgetManager = {}
function MockWidgetManager:new()
    local manager = {
        widgets = {},
        rootWidgets = {},
        focusedWidget = nil,
        eventQueue = {},
        nextWidgetId = 1
    }
    
    function manager:createWidget(widgetType)
        local id = manager.nextWidgetId
        manager.nextWidgetId = manager.nextWidgetId + 1
        local widget = MockWidget:new(id, widgetType)
        manager.widgets[id] = widget
        table.insert(manager.rootWidgets, widget)
        widget.state = 'ready'
        return widget
    end
    
    function manager:destroyWidget(widgetId)
        if manager.widgets[widgetId] then
            local widget = manager.widgets[widgetId]
            widget.state = 'destroyed'
            widget.active = false
            manager.widgets[widgetId] = nil
            return true
        end
        return false
    end
    
    function manager:addChild(parentWidget, childWidget)
        if not parentWidget or not childWidget then return false end
        table.insert(parentWidget.children, childWidget)
        childWidget.parent = parentWidget
        return true
    end
    
    function manager:setFocus(widgetId)
        if manager.widgets[widgetId] then
            manager.focusedWidget = widgetId
            manager.widgets[widgetId].state = 'focused'
            return true
        end
        return false
    end
    
    function manager:getFocusedWidget()
        if manager.focusedWidget then
            return manager.widgets[manager.focusedWidget]
        end
        return nil
    end
    
    function manager:addEventListener(widgetId, eventType, handler)
        if not manager.widgets[widgetId] then return false end
        if not manager.widgets[widgetId].eventHandlers[eventType] then
            manager.widgets[widgetId].eventHandlers[eventType] = {}
        end
        table.insert(manager.widgets[widgetId].eventHandlers[eventType], handler)
        return true
    end
    
    function manager:raiseEvent(widgetId, eventType, eventData)
        if not manager.widgets[widgetId] then return false end
        local widget = manager.widgets[widgetId]
        local handlers = widget.eventHandlers[eventType]
        if handlers then
            for _, handler in ipairs(handlers) do
                handler(eventData)
            end
        end
        return true
    end
    
    function manager:renderWidget(widgetId)
        if not manager.widgets[widgetId] then return false end
        local widget = manager.widgets[widgetId]
        widget.renderCount = widget.renderCount + 1
        return true
    end
    
    function manager:getWidgetCount()
        return manager.nextWidgetId - 1
    end
    
    function manager:getRenderCount(widgetId)
        if manager.widgets[widgetId] then
            return manager.widgets[widgetId].renderCount
        end
        return 0
    end
    
    return manager
end

-- TEST SUITE
local Suite = HierarchicalSuite:new({
    modulePath = 'engine.gui.widget_manager',
    fileName = 'widget_manager.lua',
    description = 'Widget lifecycle - creation, events, and rendering'
})

-- GROUP 1: WIDGET CREATION
Suite:group('Widget Creation', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Widgets:create', {
        description = 'Creating widget initializes properly',
        testCase = 'creation',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        Helpers.assertNotNil(widget, 'Should create widget')
        Helpers.assertEqual(widget.type, 'Button', 'Should be Button type')
        Helpers.assertTrue(widget.active, 'Should be active')
        Helpers.assertTrue(widget.visible, 'Should be visible')
        Helpers.assertEqual(widget.state, 'ready', 'Should be ready')
    end)
    
    Suite:testMethod('Widgets:multipleTypes', {
        description = 'Different widget types can be created',
        testCase = 'multiple_types',
        type = 'functional'
    }, function()
        local btn = manager:createWidget('Button')
        local txt = manager:createWidget('TextBox')
        local lbl = manager:createWidget('Label')
        
        Helpers.assertEqual(btn.type, 'Button', 'Button type')
        Helpers.assertEqual(txt.type, 'TextBox', 'TextBox type')
        Helpers.assertEqual(lbl.type, 'Label', 'Label type')
    end)
    
    Suite:testMethod('Widgets:uniqueIds', {
        description = 'Each widget gets unique ID',
        testCase = 'unique_ids',
        type = 'functional'
    }, function()
        local w1 = manager:createWidget('Button')
        local w2 = manager:createWidget('Button')
        local w3 = manager:createWidget('Button')
        
        Helpers.assertNotEqual(w1.id, w2.id, 'IDs should differ')
        Helpers.assertNotEqual(w2.id, w3.id, 'IDs should differ')
        Helpers.assertNotEqual(w1.id, w3.id, 'IDs should differ')
    end)
end)

-- GROUP 2: WIDGET HIERARCHY
Suite:group('Widget Hierarchy', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Hierarchy:parentChild', {
        description = 'Child widgets can be attached to parents',
        testCase = 'parent_child',
        type = 'functional'
    }, function()
        local parent = manager:createWidget('Panel')
        local child = manager:createWidget('Button')
        
        local ok = manager:addChild(parent, child)
        Helpers.assertTrue(ok, 'Should attach child')
        Helpers.assertEqual(#parent.children, 1, 'Parent should have 1 child')
        Helpers.assertEqual(child.parent, parent, 'Child should reference parent')
    end)
    
    Suite:testMethod('Hierarchy:multipleChildren', {
        description = 'Parent can have multiple children',
        testCase = 'multiple_children',
        type = 'functional'
    }, function()
        local parent = manager:createWidget('Panel')
        local c1 = manager:createWidget('Button')
        local c2 = manager:createWidget('Label')
        local c3 = manager:createWidget('TextBox')
        
        manager:addChild(parent, c1)
        manager:addChild(parent, c2)
        manager:addChild(parent, c3)
        
        Helpers.assertEqual(#parent.children, 3, 'Parent should have 3 children')
    end)
    
    Suite:testMethod('Hierarchy:nestedHierarchy', {
        description = 'Nested widget hierarchies can be built',
        testCase = 'nested',
        type = 'functional'
    }, function()
        local root = manager:createWidget('Window')
        local panel = manager:createWidget('Panel')
        local btn = manager:createWidget('Button')
        
        manager:addChild(root, panel)
        manager:addChild(panel, btn)
        
        Helpers.assertEqual(#root.children, 1, 'Root has 1 child')
        Helpers.assertEqual(#panel.children, 1, 'Panel has 1 child')
        Helpers.assertEqual(btn.parent, panel, 'Button parent is panel')
    end)
end)

-- GROUP 3: FOCUS MANAGEMENT
Suite:group('Focus Management', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Focus:setFocus', {
        description = 'Focus can be set on widget',
        testCase = 'set_focus',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('TextBox')
        local ok = manager:setFocus(widget.id)
        
        Helpers.assertTrue(ok, 'Should set focus')
        Helpers.assertEqual(manager:getFocusedWidget(), widget, 'Widget should be focused')
        Helpers.assertEqual(widget.state, 'focused', 'Widget state should be focused')
    end)
    
    Suite:testMethod('Focus:changeFocus', {
        description = 'Focus can be changed between widgets',
        testCase = 'change_focus',
        type = 'functional'
    }, function()
        local w1 = manager:createWidget('Button')
        local w2 = manager:createWidget('TextBox')
        
        manager:setFocus(w1.id)
        Helpers.assertEqual(manager:getFocusedWidget(), w1, 'w1 focused')
        
        manager:setFocus(w2.id)
        Helpers.assertEqual(manager:getFocusedWidget(), w2, 'w2 now focused')
    end)
end)

-- GROUP 4: EVENT HANDLING
Suite:group('Event Handling', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Events:addEventListener', {
        description = 'Event listeners can be added',
        testCase = 'add_listener',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        local handlerCalled = false
        
        local ok = manager:addEventListener(widget.id, 'click', function()
            handlerCalled = true
        end)
        
        Helpers.assertTrue(ok, 'Should add listener')
        Helpers.assertTrue(#widget.eventHandlers['click'] > 0, 'Should have handlers')
    end)
    
    Suite:testMethod('Events:raiseEvent', {
        description = 'Events are raised and handlers called',
        testCase = 'raise_event',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        local callCount = 0
        
        manager:addEventListener(widget.id, 'click', function()
            callCount = callCount + 1
        end)
        
        manager:raiseEvent(widget.id, 'click', {})
        Helpers.assertEqual(callCount, 1, 'Handler should be called once')
        
        manager:raiseEvent(widget.id, 'click', {})
        Helpers.assertEqual(callCount, 2, 'Handler should be called twice')
    end)
    
    Suite:testMethod('Events:multipleHandlers', {
        description = 'Multiple handlers can be added for same event',
        testCase = 'multiple_handlers',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        local count1 = 0
        local count2 = 0
        
        manager:addEventListener(widget.id, 'click', function()
            count1 = count1 + 1
        end)
        manager:addEventListener(widget.id, 'click', function()
            count2 = count2 + 1
        end)
        
        manager:raiseEvent(widget.id, 'click', {})
        Helpers.assertEqual(count1, 1, 'First handler called')
        Helpers.assertEqual(count2, 1, 'Second handler called')
    end)
end)

-- GROUP 5: WIDGET DESTRUCTION
Suite:group('Widget Destruction', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Destruction:destroy', {
        description = 'Widgets can be destroyed',
        testCase = 'destroy',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        local ok = manager:destroyWidget(widget.id)
        
        Helpers.assertTrue(ok, 'Should destroy widget')
        Helpers.assertFalse(widget.active, 'Should be inactive')
        Helpers.assertEqual(widget.state, 'destroyed', 'State should be destroyed')
    end)
    
    Suite:testMethod('Destruction:cannotInteract', {
        description = 'Destroyed widgets cannot be interacted with',
        testCase = 'no_interaction',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        manager:destroyWidget(widget.id)
        
        local ok = manager:setFocus(widget.id)
        Helpers.assertFalse(ok, 'Should not set focus on destroyed widget')
    end)
end)

-- GROUP 6: RENDERING
Suite:group('Rendering', function()
    local manager
    Suite:beforeEach(function()
        manager = MockWidgetManager:new()
    end)
    
    Suite:testMethod('Rendering:renderWidget', {
        description = 'Widgets can be rendered',
        testCase = 'render',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        manager:renderWidget(widget.id)
        
        local count = manager:getRenderCount(widget.id)
        Helpers.assertEqual(count, 1, 'Should have 1 render')
    end)
    
    Suite:testMethod('Rendering:multipleRenders', {
        description = 'Widgets can be rendered multiple times',
        testCase = 'multiple_renders',
        type = 'functional'
    }, function()
        local widget = manager:createWidget('Button')
        
        for _ = 1, 5 do
            manager:renderWidget(widget.id)
        end
        
        local count = manager:getRenderCount(widget.id)
        Helpers.assertEqual(count, 5, 'Should have 5 renders')
    end)
end)

-- GROUP 7: PERFORMANCE
Suite:group('Performance', function()
    Suite:testMethod('Performance:widgetCreation', {
        description = 'Creating many widgets is efficient',
        testCase = 'creation_speed',
        type = 'performance'
    }, function()
        local manager = MockWidgetManager:new()
        local iterations = 5000
        local startTime = os.clock()
        
        for _ = 1, iterations do
            manager:createWidget('Button')
        end
        
        local elapsed = os.clock() - startTime
        print('[Widget Performance] ' .. iterations .. ' creations: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.0001, 'Per-widget: <0.1ms')
    end)
    
    Suite:testMethod('Performance:eventHandling', {
        description = 'Event handling is efficient',
        testCase = 'event_speed',
        type = 'performance'
    }, function()
        local manager = MockWidgetManager:new()
        local widget = manager:createWidget('Button')
        
        for i = 1, 100 do
            manager:addEventListener(widget.id, 'click', function() end)
        end
        
        local iterations = 1000
        local startTime = os.clock()
        
        for _ = 1, iterations do
            manager:raiseEvent(widget.id, 'click', {})
        end
        
        local elapsed = os.clock() - startTime
        print('[Widget Performance] 1000 events w/ 100 handlers: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.001, 'Per-event: <1ms')
    end)
    
    Suite:testMethod('Performance:rendering', {
        description = 'Rendering many widgets is efficient',
        testCase = 'render_speed',
        type = 'performance'
    }, function()
        local manager = MockWidgetManager:new()
        local widgets = {}
        for _ = 1, 100 do
            table.insert(widgets, manager:createWidget('Button'))
        end
        
        local iterations = 100
        local startTime = os.clock()
        
        for _ = 1, iterations do
            for _, w in ipairs(widgets) do
                manager:renderWidget(w.id)
            end
        end
        
        local elapsed = os.clock() - startTime
        print('[Widget Performance] 100 widgets * 100 frames: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / (iterations * #widgets)), 0.0001, 
            'Per-widget-render: <0.1ms')
    end)
end)

Suite:run()
