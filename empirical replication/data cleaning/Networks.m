%construct networks
function [] = Networks(w)

village = csvread(strcat('village',num2str(w),'.csv'));

% Household ID's and Person ID's
hhids = mod( village(:,1), 1000 );
pids = village(:,2);
numHouseholds = max(hhids);

households = zeros(numHouseholds,9);

persons = 100*village(:,1) + village(:,2);
%number of person
numPersons = length(persons);

% Populate the mappings and household structures
for curID=1:numPersons
  
  person = persons(curID);
  hhid = hhids(curID);
  pid = pids(curID);
  
  % It turns out that octave/matlab will not let the field of a structure begin with a number
  % So we add letters before the numbers
  personField = ['P',num2str(person)];
  
  % Update the maps
  personToID.(personField) = curID;
  IDtoPerson(curID) = person;
  
  % Update the household structure
  households(hhid,pid) = curID;
  
end


% Now we will build the "base" adjacency matrix, in which nodes which belong
% to the same household are connected
baseAdjMat = zeros(numPersons,numPersons);

housesize=zeros(numHouseholds,1);
% Look through the households 
for h = 1:numHouseholds
  
  % Within the household, we want all the pairs of PID's
  % (i,j) for i != j
  for i = 1:max(village(:,2))
    
    % No more ID's left in this household
    if ~households(h,i)
      housesize(h,1)=i-1;
      break;
    end
    
    basePerson = households(h,i);
    
    % Match i with its pairing, j
    for j = i+1:max(village(:,2))
      
      % No more ID's to pair with
      if ~households(h,j)
        break;
      end
      
      curPerson = households(h,j);
      
      % Add vertices
      baseAdjMat(basePerson,curPerson) = 1;
      baseAdjMat(curPerson,basePerson) = 1;
      
    end
    
  end
  if i==max(village(:,2))&housesize(h,1)==0
      housesize(h,1)=max(village(:,2));
  end

end

relationships = ...
  {
    strcat('visitgo',num2str(w));
    strcat('visitcome',num2str(w));
    strcat('nonrel',num2str(w));
    strcat('medic',num2str(w));
    strcat('keroricego',num2str(w));
    strcat('keroricecome',num2str(w));
    strcat('borrowmoney',num2str(w));
    strcat('lendmoney',num2str(w));
    strcat('helpdecision',num2str(w));
    %strcat('locleader',num2str(w));
    strcat('giveadvice',num2str(w));
    strcat('templecompany',num2str(w));
    strcat('rel',num2str(w));
  };

numRelationships = size(relationships,1);

villageRelationships = zeros(numPersons,numPersons,numRelationships);

% Walk through each relationship
for relationshipID=1:numRelationships
  curRelationship = relationships{relationshipID};
  
  % Read in the relationship info as a List of Lists (LoL)
  LoL = csvread([ curRelationship, '.csv' ]);
  
  % Start building the Adjacency Matrix
  adjMat = zeros(numPersons,numPersons);
  
  for i = 1:size(LoL,1)
    
    % The first cell in a row is the ID of the base person
    basePerson = LoL(i,1);
    if (basePerson == 0)
      continue;
    end
    
    % Find the ID mapping
    basePersonField = ['P',num2str(basePerson)];
    if ~isfield(personToID,basePersonField)
      %disp(['Warning: When processing relationship ', curRelationship, ...
          %  ' could not find HHIDPID ', basePersonField, ' in village table']);
        %disp(['...occured on row ', num2str(i), ', column ', num2str(1), ...
            %  ' of file ', curRelationship, '.csv']);
      continue;
    end
    
    baseID = personToID.(basePersonField);

    % The remaining cells in the row are the links to other people that were
    % given by the base person
    for j = 2:size(LoL,2)

      curPerson = LoL(i,j);
      if curPerson==0 % If it's a zero there is nothing to process
        continue
      end
      
      % Find the ID mapping for the person
      curPersonField = ['P',num2str(curPerson)];
      if ~isfield(personToID,curPersonField)
        %disp(['Warning: When processing relationship ', curRelationship, ...
            %  ' could not find HHIDPID ', curPersonField, ' in village table']);
        %disp(['...occured on row ', num2str(i), ', column ', num2str(j), ...
            %  ' of file ', curRelationship, '.csv']);
        continue;
      end
      curID = personToID.(curPersonField);
      
      % Make the relevant updates to the adjacency matrix
      adjMat(baseID,curID) = 1;
      adjMat(curID,baseID) = 1;
      
    end
  end
  
  % Put the matrix into the village relationships structure
  villageRelationships(:,:,relationshipID) = adjMat;
  
end

savename = sprintf('/Users/network/Netwroks_%d.mat', w);
save(savename,'villageRelationships','IDtoPerson','personToID')


