function track_nucs(cpath,sav_path,max_linking_distance,max_gap_closing)
% reads in the label matrices generated by segment_images, does tracking
% and makes new label matrices with the correct colors
    
lpath=[sav_path,'_Ltif\']; %on camA
cL=dir(strcat(lpath,'*CamA*.tif'));
clear points nucs_list
for ct=1:size(cL,1)  % go through each time
    cstackL=loadtiff([lpath,cL(ct).name]);  % load in label matrix  
    b=regionprops(cstackL,'Centroid'); % calculate region props
    clear point_temp % temp points variable
    for cp=1:size(b,1)    
        point_temp(cp,1:3)=b(cp).Centroid; % assemble into a matrix in a temp array  
        point_temp(cp,4)=cp; % previous label
        point_temp(cp,5)=ct; %current frame
    end 
    points{ct}=point_temp(:,1:3); % write to array for tracking
    nucs_list{ct}=point_temp; % make a nucs list cell array that will be updated after tracking  
end

nucs_list= vertcat(nucs_list{:}); % make the cell array into a matrix


 [ tracks, adjacency_tracks ] = simpletracker(points,...
        'MaxLinkingDistance', max_linking_distance, ...
        'MaxGapClosing', max_gap_closing, ...
        'Debug', false); % run tracking

for i_track = 1 : size(adjacency_tracks,1) % now add the track IDs to the right column
    track = adjacency_tracks{i_track};
    nucs_list(track,6)=i_track;   
end

% now remake label matrices with correct colors
tracked_path=[sav_path,'_L_tracktif\']; %on camA; 
mkdir(tracked_path)
parfor ct=1:size(cL,1) 
    ct
    cstackL=loadtiff([lpath,cL(ct).name]);   
    cnucs_list=nucs_list(nucs_list(:,5)==ct,:); % current nuc list
    to_change=cnucs_list(cnucs_list(:,4)~=cnucs_list(:,6),:);
    cstackL2=cstackL;% copyL
    for cch=1:size(to_change,1)
        cstackL2(cstackL==to_change(cch,4))=to_change(cch,6); % change label
    end
    write3Dtiff(cstackL2,[tracked_path,cL(ct).name])    
end

       
end
