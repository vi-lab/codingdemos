classdef testguiclass < handle
%TESTGUICLASS Summary of this class goes here
%   Detailed explanation goes here

   properties
       hMainWindow
       hButton
       hTextElement
       listener
       hCoeffTable
       hCoeffOptions
   end
   properties (SetObservable = true)
       aVar
   end

   methods
       function obj = testguiclass()
           scrsz = get(0,'ScreenSize');
           obj.hMainWindow = figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
           obj.hButton = uicontrol(obj.hMainWindow, 'Style', 'pushbutton', 'String', 'Clear', 'Position', [20 150 100 70], 'Callback', {@testguiclass.buttonCallback, obj});
           obj.hTextElement = uicontrol(obj.hMainWindow, 'Style', 'text', 'String', 'hi', 'Position',[100 150 100 70]);
           obj.aVar = 1;
           obj.listener = addlistener(obj,'aVar','PostSet',@(src,evnt)handlePropertyEvents(obj,src,evnt));
           
           dat = cell(8,8);
           dat(1:end,1:end) = {true};
           col_name = cell(1,8);
           col_name(1,1:end) = {'1','2','3','4','5','6','7','8'};
           col_format = cell(1,8);
           col_format(1,1:end) = {[]};
           col_editable = logical(ones(1,8));
           
           % 'Units','normalized',
           obj.hCoeffOptions = uitable('Position',[300 250 400 400], 'ColumnWidth', {25}, 'Data', dat,... 
            'ColumnName', col_name,...
            'ColumnFormat', col_format,...
            'ColumnEditable', col_editable);
       end
       
       function buttonCallback(hObject, eventdata, obj)
           set(obj.hMainWindow, 'Color', 'b');
           obj.aVar = 2;
       end
       
       function handlePropertyEvents(obj, source, event)
           switch source.Name
               case 'aVar'
                   set(obj.hTextElement, 'String', 'ok');
           end
       end
   end
end 
