pageextension 50181 CustomerCardExt extends "Customer Card"
{
    layout
    {
        addlast(General)
        {

            field(StartTime; StartTime)
            {
                ApplicationArea = All;
                Caption = 'Start Time';
                Editable = false;
            }

            field(DurationTime; DurationTime)
            {
                ApplicationArea = All;
                Caption = 'Duration';
                Editable = false;
            }

            field(EndTime; EndTime)
            {
                ApplicationArea = All;
                Caption = 'End Time';
                Editable = false;
            }
        }
    }

    var
        // Global variable used for the TaskID
        WaitTaskId: Integer;

        // Variables for the three fields on the page 
        StartTime: Text;
        DurationTime: Text;
        EndTime: Text;

    trigger OnAfterGetRecord()
    var
        //Defines a variable for passing parameters to the background task
        TaskParameters: Dictionary of [Text, Text];
    begin
        TaskParameters.Add('Wait', '1000');

        CurrPage.EnqueueBackgroundTask(WaitTaskId, 50181, TaskParameters, 1000, PageBackgroundTaskErrorLevel::Warning);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        started: Text;
        waited: Text;
        finished: Text;
        PBTNotification: Notification;
    begin
        if (TaskId = WaitTaskId) then begin
            Evaluate(started, Results.Get('started'));
            Evaluate(waited, Results.Get('waited'));
            Evaluate(finished, Results.Get('finished'));

            StartTime := started;
            DurationTime := waited;
            EndTime := finished;
            PBTNotification.Message('Start and finish times have been updated.');
            PBTNotification.Send();
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        PBTErrorNotification: Notification;
    begin
        if (ErrorText = 'Could not parse parameter WaitParam') then begin
            IsHandled := true;
            PBTErrorNotification.Message('Something went wrong. The start and finish times have been updated.');
            PBTErrorNotification.Send();
        end

        else
            if (ErrorText = 'Child Session task was terminated because of a timeout.') then begin
                IsHandled := true;
                PBTErrorNotification.Message('It took to long to get results. Try again.');
                PBTErrorNotification.Send();
            end
    end;
}