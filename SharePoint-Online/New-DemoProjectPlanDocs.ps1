# Requires: Import-Module -Name ImportExcel, Import-Module -Name PSWriteWord (or use Word COM automation)

# Ensure output directory exists
$outputDir = "C:\temp"
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}

$people=@(
    "user01@example.com",
    "user02@example.com",
    "user03@example.com",
    "user04@example.com",
    "user05@example.com",
    "user06@example.com",
    "user07@example.com",
    "user08@example.com",
    "user09@example.com",
    "user10@example.com",
    "user11@example.com",
    "user12@example.com",
    "user13@example.com",
    "user14@example.com",
    "user15@example.com",
    "user16@example.com",
    "user17@example.com",
    "user18@example.com",
    "user19@example.com",
    "user20@example.com",
    "user21@example.com",
    "user22@example.com",
    "user23@example.com",
    "user24@example.com",
    "user25@example.com"
)

foreach ($proj in $projectSites) {
    # Load Word COM object
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false

    $projNum = [int]($proj.Title -replace '[^\d]', '')
    $fileName = "Project $projNum Plan.docx"
    $filePath = "c:\temp\$fileName"
    if (Test-Path $filePath) {
        Write-Host "File $fileName already exists, skipping creation." -ForegroundColor Yellow
        continue
    } else {
        Write-Host "Creating $fileName." -ForegroundColor Green

        # Generate random team size (7-10 people) and assign random people from $people array
        $teamSize = Get-Random -Minimum 7 -Maximum 11
        $teamMembers = $people | Get-Random -Count $teamSize | Sort-Object
        $projectManager = $people | Get-Random
        
        # Create team member list string
        $teamMemberList = $teamMembers -join ", "

        # Create new document
        $doc = $word.Documents.Add()

        # Add Title
        $selection = $word.Selection
        $selection.Style = "Title"
        $selection.TypeText("$($proj.Region) - Project $projNum Plan")
        $selection.TypeParagraph()

        # Project Team Heading
        $selection.Style = "Heading 1"
        $selection.TypeText("Project Team")
        $selection.TypeParagraph()
        $selection.TypeText("Project Manager: $projectManager")
        $selection.TypeParagraph()
        $selection.TypeText("Team Members: $teamMemberList")
        $selection.TypeParagraph()

        # Issues Heading
        $selection.Style = "Heading 1"
        $selection.TypeText("Issues")
        $selection.TypeParagraph()
        $selection.TypeText("No current issues.")
        $selection.Style = "Normal"
        $selection.TypeParagraph()

        # Risks Heading
        $selection.Style = "Heading 1"
        $selection.TypeText("Risks")
        $selection.TypeParagraph()
        $selection.TypeText("No significant risks identified at this stage.")        
        $selection.Style = "Normal"
        $selection.TypeParagraph()

        # Plan Details Heading
        $selection.Style = "Heading 1"
        $selection.TypeText("Plan Details")
        $selection.TypeParagraph()

        # Example tasks
        $tasks = @(
            @{ Name = "Kickoff Meeting" },
            @{ Name = "Requirements Gathering" },
            @{ Name = "Design Solution" },
            @{ Name = "Develop Prototype" },
            @{ Name = "Review Prototype" },
            @{ Name = "Finalize Requirements" },
            @{ Name = "Develop Solution" },
            @{ Name = "Unit Testing" },
            @{ Name = "Integration Testing" },
            @{ Name = "User Acceptance Testing" },
            @{ Name = "Documentation" },
            @{ Name = "Training" },
            @{ Name = "Deployment" },
            @{ Name = "Post Go-Live Support" },
            @{ Name = "Project Closure" },
            @{ Name = "Lessons Learned" },
            @{ Name = "Archive Artifacts" },
            @{ Name = "Celebrate Success" }
        )

        # Randomly assign tasks to team members (including project manager)
        $allTeamMembers = @($projectManager) + $teamMembers
        $tasksWithOwners = foreach ($task in $tasks) {
            $randomOwner = $allTeamMembers | Get-Random
            @{ Name = $task.Name; Owner = $randomOwner }
        }

        $today = Get-Date
        $startDate = $today.AddDays($projNum)
        $taskCount = $tasksWithOwners.Count
        $taskDuration = 3 # days per task

        # Add table for tasks
        $table = $doc.Tables.Add($selection.Range, $taskCount + 1, 4)
        $table.Cell(1,1).Range.Text = "Task"
        $table.Cell(1,2).Range.Text = "Start Date"
        $table.Cell(1,3).Range.Text = "End Date"
        $table.Cell(1,4).Range.Text = "Owner"
        $table.Style = "Medium Shading 1 - Accent 1"

        for ($i = 0; $i -lt $taskCount; $i++) {
            $task = $tasksWithOwners[$i]
            $taskStart = $startDate.AddDays($i * $taskDuration)
            $taskEnd = $taskStart.AddDays($taskDuration - 1)
            $row = $i + 2
            $table.Cell($row,1).Range.Text = $task.Name
            $table.Cell($row,2).Range.Text = $taskStart.ToString("yyyy-MM-dd")
            $table.Cell($row,3).Range.Text = $taskEnd.ToString("yyyy-MM-dd")
            $table.Cell($row,4).Range.Text = $task.Owner
        }
        $selection.MoveDown(5, $taskCount + 2)
        $selection.TypeParagraph()

        # Save and close document
        $doc.SaveAs([ref]$filePath)
        $doc.Close()
        $word.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
} #foreach