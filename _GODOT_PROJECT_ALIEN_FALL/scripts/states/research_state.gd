extends Control
class_name ResearchState

# ResearchState - Handles the research screen
# Shows available, active, and completed research projects

@onready var available_research_list = $MainContainer/LeftPanel/AvailableResearchList
@onready var active_research_list = $MainContainer/RightPanel/ActiveResearchList
@onready var completed_research_list = $MainContainer/RightPanel/CompletedResearchList
@onready var back_button = $BottomPanel/BackButton

func _ready():
    print("ResearchState: Initializing...")
    
    # Connect UI signals
    back_button.connect("pressed", Callable(self, "_on_back_pressed"))
    
    # Connect to research manager signals
    ResearchManager.connect("research_started", Callable(self, "_on_research_started"))
    ResearchManager.connect("research_completed", Callable(self, "_on_research_completed"))
    ResearchManager.connect("research_progress_updated", Callable(self, "_on_research_progress_updated"))
    
    # Initialize UI
    _update_display()
    
    print("ResearchState: Ready")

func _update_display():
    _update_available_research()
    _update_active_research()
    _update_completed_research()

func _update_available_research():
    # Clear existing research
    for child in available_research_list.get_children():
        child.queue_free()
    
    var available_projects = ResearchManager.get_available_research_projects()
    
    if available_projects.size() == 0:
        var no_research_label = Label.new()
        no_research_label.text = "No research available\n(Build more laboratories or complete prerequisites)"
        available_research_list.add_child(no_research_label)
        return
    
    for project in available_projects:
        var project_container = VBoxContainer.new()
        available_research_list.add_child(project_container)
        
        var name_label = Label.new()
        name_label.text = project.name
        project_container.add_child(name_label)
        
        var desc_label = Label.new()
        desc_label.text = project.description
        desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
        project_container.add_child(desc_label)
        
        var cost_label = Label.new()
        cost_label.text = "Cost: %d scientist-days, Requires: %d scientists" % [project.research_cost, project.scientists_required]
        project_container.add_child(cost_label)
        
        var start_button = Button.new()
        start_button.text = "START RESEARCH"
        start_button.connect("pressed", Callable(self, "_on_start_research_pressed").bind(project.project_id))
        project_container.add_child(start_button)
        
        # Add separator
        var separator = HSeparator.new()
        project_container.add_child(separator)

func _update_active_research():
    # Clear existing research
    for child in active_research_list.get_children():
        child.queue_free()
    
    var active_projects = ResearchManager.get_active_research()
    
    if active_projects.size() == 0:
        var no_research_label = Label.new()
        no_research_label.text = "No active research"
        active_research_list.add_child(no_research_label)
        return
    
    for active_project in active_projects:
        var project = ResearchManager.get_research_project(active_project.project_id)
        var progress = active_project.progress
        
        var project_container = VBoxContainer.new()
        active_research_list.add_child(project_container)
        
        var name_label = Label.new()
        name_label.text = project.name
        project_container.add_child(name_label)
        
        var progress_label = Label.new()
        progress_label.text = "Progress: %.1f%%" % (progress * 100)
        project_container.add_child(progress_label)
        
        var progress_bar = ProgressBar.new()
        progress_bar.value = progress * 100
        progress_bar.show_percentage = false
        project_container.add_child(progress_bar)
        
        var cancel_button = Button.new()
        cancel_button.text = "CANCEL"
        cancel_button.connect("pressed", Callable(self, "_on_cancel_research_pressed").bind(project.project_id))
        project_container.add_child(cancel_button)
        
        # Add separator
        var separator = HSeparator.new()
        project_container.add_child(separator)

func _update_completed_research():
    # Clear existing research
    for child in completed_research_list.get_children():
        child.queue_free()
    
    var completed_projects = ResearchManager.get_completed_research()
    
    if completed_projects.size() == 0:
        var no_research_label = Label.new()
        no_research_label.text = "No completed research"
        completed_research_list.add_child(no_research_label)
        return
    
    for project_id in completed_projects:
        var project = ResearchManager.get_research_project(project_id)
        
        var project_label = Label.new()
        project_label.text = "✓ " + project.name
        completed_research_list.add_child(project_label)

func _on_start_research_pressed(project_id: String):
    if ResearchManager.start_research(project_id):
        _update_display()
        _show_message("Started research: " + ResearchManager.get_research_project(project_id).name)
    else:
        _show_error("Failed to start research")

func _on_cancel_research_pressed(project_id: String):
    if ResearchManager.cancel_research(project_id):
        _update_display()
        _show_message("Cancelled research: " + ResearchManager.get_research_project(project_id).name)
    else:
        _show_error("Failed to cancel research")

func _on_back_pressed():
    print("ResearchState: Back to geoscape requested")
    
    # Return to geoscape
    get_tree().change_scene_to_file("res://scenes/geoscape.tscn")

func _on_research_started(project_id: String):
    print("ResearchState: Research started: ", project_id)
    _update_display()

func _on_research_completed(project_id: String):
    print("ResearchState: Research completed: ", project_id)
    _update_display()
    _show_message("Research completed: " + ResearchManager.get_research_project(project_id).name)

func _on_research_progress_updated(project_id: String, progress: float):
    # Update progress bars for active research
    _update_active_research()

func _show_message(message: String):
    var dialog = AcceptDialog.new()
    dialog.title = "Information"
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()

func _show_error(message: String):
    var dialog = AcceptDialog.new()
    dialog.title = "Error"
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()
