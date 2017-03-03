step = 0;
for s = [3:4 7:20 22 24:25 29]
    step = step + 1;
    ACS_BIS(step,:) = csvread(['ACS_BIS summary s' num2str(s) '.csv']);
end

fid1 = fopen('AllSubsACSBISData.csv','w');
fprintf(fid1,'Participant,');
fprintf(fid1, 'ACS total,');
fprintf(fid1, 'attention1,');
fprintf(fid1,'cog_instability1,');
fprintf(fid1,'motor1,');
fprintf(fid1,'perseverance1,');
fprintf(fid1,'self_control1,');
fprintf(fid1,'cog_complexity1,');
fprintf(fid1,'ATTENTION2,');
fprintf(fid1,'MOTOR2,');
fprintf(fid1,'NONPLAN2,');
fprintf(fid1,'TOTAL,');
fprintf(fid1,'\n')

for ss = 1:step
        fprintf(fid1,'%8.4f,', ACS_BIS(ss,:));
        fprintf(fid1,'\n');
end

fclose(fid1);