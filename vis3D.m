function [f,BW] = vis3D(image);
% vis3D() is a GUI that let's you visualize any 3D data matrix as 3
% slices in x,y, and z. Crosshairs show the intersection of the planes and
% can be turned off using the checkbox. Three buttons let you save the
% current slides in a .fig form with proper titles and without crosshairs, 
% select and save a ROI, and close the program without error.
%
%
%  INPUTS: image    = 3D double, data cube
%
%  OUTPUT: f        = figure window, runs until paused or program closed
%          BW       = array of ROI data, w/ all other datapoints at 0
%                     (returns as 0 if no ROI is specified)
%
%  Author: Rickard Stureborg
%  Date:   15JUN2018

    BW=0;
    close all
    handles.stopvar = 0;
    handles.image = image;
    handles.BW = 0; handles.roicount = {0};
    
    handles.xdim = (1:size(image,1));
    handles.ydim = (1:size(image,2));
    handles.zdim = (1:size(image,3));
    %default slices at middle of image
    handles.xslice = fix(size(handles.xdim,2)/2);
    handles.yslice = fix(size(handles.ydim,2)/2);
    handles.zslice = fix(size(handles.zdim,2)/2);

    f = figure('units','normalized','outerposition',[0 0 1 1]);
    x = subplot(2,2,4); grid on;         
    y = subplot(2,2,3); grid on;
    z = subplot(2,2,1); grid on;
    
    %slider for x
    handles.zslider = uicontrol('Parent',f,'Style','slider','Position',[279,415,300,23],...
                    'value',handles.zslice, 'min',1, 'max',size(handles.zdim,2)); 
                    bgcolor = f.Color;
    %text for slider
    uicontrol('Parent',f,'Style','text','Position',[250,415,23,23],...    
                    'String','1','BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[585,415,23,23],...
                    'String',num2str(size(handles.zdim,2)),'BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[378,400,100,23],...
                    'String','Z Slide','BackgroundColor',bgcolor);     
    %slider for y
    handles.yslider = uicontrol('Parent',f,'Style','slider','Position',[279,30,300,23],...
                    'value',handles.yslice, 'min',1, 'max',size(handles.ydim,2)); 
                    bgcolor = f.Color;
              
    uicontrol('Parent',f,'Style','text','Position',[250,30,23,23],...
                    'String','1','BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[585,30,23,23],...
                    'String',num2str(size(handles.ydim,2)),'BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[378,15,100,23],...
                    'String','Y Slide','BackgroundColor',bgcolor);
    %slider for z
    handles.xslider = uicontrol('Parent',f,'Style','slider','Position',[920,30,290,23],...
                    'value',handles.xslice, 'min',1, 'max',size(handles.xdim,2)); 
                    bgcolor = f.Color;
                
    uicontrol('Parent',f,'Style','text','Position',[891,30,23,23],...
                    'String','1','BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[1215,30,23,23],...
                    'String',num2str(size(handles.xdim,2)),'BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Position',[1015,15,100,23],...
                    'String','X Slide','BackgroundColor',bgcolor);
    drawnow
    
    %buttons
    savebutton = uicontrol('Style', 'pushbutton', 'String', 'Save Current Slides',...
                    'Position', [980 550 150 20], 'Callback', @savecallback,'UserData',handles);
    closebutton = uicontrol('Style', 'pushbutton', 'String', 'Close Program',...
                    'Position', [980 610 150 20], 'Callback', @closecallback,'UserData',handles);
    roibutton1 = uicontrol('Style', 'pushbutton', 'String', 'ROI',...
                    'Position', [980 670 150 20], 'Callback', @roicallback,'UserData',handles);
    handles.crosshairbox = uicontrol('Style', 'checkbox', 'String', 'Crosshairs',...
                    'Position', [800 660 150 20],'UserData',handles);
                set(handles.crosshairbox,'value',1);
    
    while 1

        if handles.stopvar == 1
            close all
            break
        end
        handles.xslice = round(get(handles.xslider,'value'));
        handles.yslice = round(get(handles.yslider,'value'));
        handles.zslice = round(get(handles.zslider,'value')); 
        guidata(savebutton, handles);

        lc = 0;%linecolor
        f = figure(1);
        handles.x = subplot(2,2,4); grid on;
        xdata = squeeze(image(handles.xslice,:,:)); 
        if get(handles.crosshairbox,'value') == 1; 
            xdata(:,handles.zslice)= lc; xdata(handles.yslice,:)= lc; end
        if handles.roicount{1} == '3'; 
            handles.BW = roipoly;
            BW = (handles.BW).*xdata;
            handles.roicount = {0};
        end
        handles.ximage = imagesc(handles.zdim,handles.ydim,xdata); axis image
        
        handles.y = subplot(2,2,3); grid on;
        ydata = squeeze(image(:,handles.yslice,:)); 
        if get(handles.crosshairbox,'value') == 1;
        ydata(:,handles.zslice)= lc; ydata(handles.xslice,:)= lc; end
        if handles.roicount{1} == '2'; 
            handles.BW = roipoly;
            BW = (handles.BW).*ydata;
            handles.roicount = {0};
        end
        handles.yimage = imagesc(handles.zdim,handles.xdim,ydata); axis image
        
        handles.z = subplot(2,2,1); grid on;
        zdata = squeeze(image(:,:,handles.zslice));
        if get(handles.crosshairbox,'value') == 1;
        zdata(:,handles.yslice)= lc; zdata(handles.xslice,:)= lc; end
        if handles.roicount{1} == '1'; 
            handles.BW = roipoly;
            BW = (handles.BW).*zdata;
            handles.roicount = {0};
        end
        handles.zimage = imagesc(handles.ydim,handles.xdim,zdata); axis image
        drawnow
        
    end
    
    disp(['vis3D was stopped at ',datestr(datetime('now'))])
end
    
function savecallback(savebutton,EventData)
    handles = evalin('caller','handles');
    
    figsave = figure;
    subplot(1,3,3); imagesc(handles.zdim,handles.ydim,...
        squeeze(handles.image(handles.xslice,:,:))); axis image
    title(['X-Slice ' num2str(handles.xslice) ' of ' num2str(size(handles.xdim,2))]);
    xlabel('Z-Position'); ylabel('Y-Position');
    subplot(1,3,2); imagesc(handles.zdim,handles.xdim,...
        squeeze(handles.image(:,handles.yslice,:))); axis image
    title(['Y-Slice ' num2str(handles.yslice) ' of ' num2str(size(handles.ydim,2))]);
    xlabel('Z-Position'); ylabel('X-Position');
    subplot(1,3,1); imagesc(handles.ydim,handles.xdim,...
        squeeze(handles.image(:,:,handles.zslice))); axis image
    title(['Z-Slice ' num2str(handles.zslice) ' of ' num2str(size(handles.zdim,2))]);
    xlabel('Y-Position'); ylabel('X-Position');
    
    savefig(figsave,['vis3Dslides_',datestr(now, 'HH_MM_SS')]);
    disp(['Slides ' num2str(handles.xslice) ', ',num2str(handles.yslice),', and '...
           ,num2str(handles.zslice),' (in X,Y, and Z) have been saved as of: '...
           ,datestr(datetime('now'))])
end

function closecallback(closebutton,EventData)  
    handles.stopvar = 1;
    assignin('caller','handles',handles);
end

function roicallback(roibutton,EventData)
    handles = evalin('caller','handles');
    
    handles.roicount = inputdlg('Graph Number (1-3)','ROI',[1 25]);
    
    assignin('caller','handles',handles);
end