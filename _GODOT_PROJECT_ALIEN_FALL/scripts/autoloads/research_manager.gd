extends Node

# ResearchManager - Manages research projects and completed technologies
# Autoload singleton for research management

var research_projects: Dictionary = {}  # project_id -> ResearchProject
var completed_research: Array = []  # List of completed research IDs
var active_projects: Array = []  # Currently active research projects

signal research_completed(project_id: String)
signal research_started(project_id: String)
signal research_progress_updated(project_id: String, progress: float)

func _ready():
    print("ResearchManager: Initializing...")
    _load_research_projects()
    print("ResearchManager: Ready")

func _load_research_projects():
    print("ResearchManager: Loading research projects...")
    
    # Load research data from data registry
    var research_data = DataRegistry.get_all_data("research")
    if research_data:
        for project_id in research_data:
            var project_data = research_data[project_id]
            var project = ResearchProject.from_data(project_data)
            research_projects[project.project_id] = project
            print("ResearchManager: Loaded research project: ", project.name)
    
    print("ResearchManager: Loaded ", research_projects.size(), " research projects")

func get_research_project(project_id: String) -> ResearchProject:
    return research_projects.get(project_id)

func get_all_research_projects() -> Array[ResearchProject]:
    return research_projects.values()

func get_available_research_projects() -> Array[ResearchProject]:
    var available = []
    for project in research_projects.values():
        if can_start_research(project.project_id):
            available.append(project)
    return available

func get_completed_research() -> Array:
    return completed_research.duplicate()

func is_research_completed(project_id: String) -> bool:
    return project_id in completed_research

func can_start_research(project_id: String) -> bool:
    if not research_projects.has(project_id):
        return false
    
    var project = research_projects[project_id]
    
    # Check if already completed
    if is_research_completed(project_id):
        return false
    
    # Check if already active
    for active_project in active_projects:
        if active_project.project_id == project_id:
            return false
    
    # Check prerequisites
    for prereq in project.prerequisites:
        if not is_research_completed(prereq):
            return false
    
    # Check if we have scientists available
    var available_scientists = BaseManager.get_personnel_by_role("scientist")
    var assigned_scientists = 0
    for scientist in available_scientists:
        if scientist.assigned_facility and scientist.assigned_facility.provides_service("research"):
            assigned_scientists += 1
    
    return assigned_scientists >= project.scientists_required

func start_research(project_id: String) -> bool:
    if not can_start_research(project_id):
        return false
    
    var project = research_projects[project_id]
    
    # Create active research entry
    var active_research = {
        "project_id": project_id,
        "progress": 0.0,
        "assigned_scientists": project.scientists_required,
        "start_day": TimeService.get_current_day()
    }
    
    active_projects.append(active_research)
    emit_signal("research_started", project_id)
    print("ResearchManager: Started research: ", project.name)
    return true

func cancel_research(project_id: String) -> bool:
    for i in range(active_projects.size()):
        if active_projects[i].project_id == project_id:
            active_projects.remove_at(i)
            print("ResearchManager: Cancelled research: ", project_id)
            return true
    return false

func process_research():
    var completed_projects = []
    
    for active_research in active_projects:
        var project = research_projects[active_research.project_id]
        
        # Calculate progress based on assigned scientists and time
        var scientists = active_research.assigned_scientists
        var days_elapsed = TimeService.get_current_day() - active_research.start_day
        
        # Simple progress calculation: scientists * days / total_cost
        var progress = float(scientists * days_elapsed) / project.research_cost
        
        active_research.progress = min(progress, 1.0)
        
        emit_signal("research_progress_updated", active_research.project_id, active_research.progress)
        
        # Check if completed
        if active_research.progress >= 1.0:
            completed_projects.append(active_research)
    
    # Complete projects
    for completed in completed_projects:
        var project_id = completed.project_id
        active_projects.erase(completed)
        completed_research.append(project_id)
        emit_signal("research_completed", project_id)
        print("ResearchManager: Completed research: ", project_id)

func get_active_research() -> Array:
    return active_projects.duplicate()

func get_research_progress(project_id: String) -> float:
    for active_research in active_projects:
        if active_research.project_id == project_id:
            return active_research.progress
    return 0.0

func save_game():
    return {
        "completed_research": completed_research.duplicate(),
        "active_projects": active_projects.duplicate()
    }

func load_game(save_data: Dictionary):
    completed_research = save_data.get("completed_research", [])
    active_projects = save_data.get("active_projects", [])
    
    print("ResearchManager: Loaded ", completed_research.size(), " completed research projects")
    print("ResearchManager: Loaded ", active_projects.size(), " active research projects")

# ResearchProject class
class ResearchProject:
    var project_id: String
    var name: String
    var description: String
    var research_cost: int  # Scientist-days required
    var scientists_required: int
    var prerequisites: Array
    var category: String
    
    func _init(id: String = "", proj_name: String = ""):
        project_id = id
        name = proj_name
    
    static func from_data(data: Dictionary) -> ResearchProject:
        var project = ResearchProject.new(data.get("id", ""), data.get("name", ""))
        project.description = data.get("description", "")
        project.research_cost = data.get("research_cost", 100)
        project.scientists_required = data.get("scientists_required", 1)
        project.prerequisites = data.get("prerequisites", [])
        project.category = data.get("category", "general")
        return project
