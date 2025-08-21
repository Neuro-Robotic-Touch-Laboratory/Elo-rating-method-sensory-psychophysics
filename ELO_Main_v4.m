%% Elo rating and ranking analisys
% The data have to be formatted following the examples of the .txt files in
% this folder. The same applies for the files name. Also some other
% parameters such as the stimuli names have to be adjusted accordingly.
% This code applies the Elo rating method to rank psychophysical stimuli.
% It generates and saves the following figures:
% - per subject indivudal Elo score
% - aggregated Elo scores with <shuffle_repetitions> shuffles (all traces)
% - aggregated Elo scores with <shuffle_repetitions> shuffles (median and inter-quartile ranges)
% - mean weighted consistency index evolution related to the number of involved subjects
% - distribution boxplots of the <shuffle_repetitions> Elo scores


% Marian Statache
% marian.statache5@gmail.com
% Sant'anna School of Advanced Studies, Pisa, Italy


% close all
clear all
clc
close all

path_main = cd;
save_figures = 1;  % =0 not saving 
%% Parameters

% I can't use the function isfile(*.txt) because of the *, so I need to
% check the size of filelist=dir()
filelist=dir('*.txt');
subjects = [];
if size(filelist,1)>1  % there's always the timings.txt file
    for i=1:size(filelist,1)-1
        subjects=[subjects; filelist(i).name];
    end
end

sn=["A-A_{#}^{ }", "A-B_{ }^{ }", "G_{#}-B^{ }", "G-B_{ }^{ }", "G-C_{ }^{ }", "F-C_{ }^{ }"]; % sample labels for figure display
color_map = [...
    4/255,   58/255,  73/255;   % #043a49
    18/255,  138/255, 181/255;  % #128ab5
    79/255,  183/255, 149/255;  % #4fb795
    254/255, 206/255, 97/255;   % #fece61
    240/255, 128/255, 94/255;   % #f0805e
    233/255, 71/255,  111/255]; % #e9476f


shuffle_repetitions=100;

n_stimuli=0;
n_subjects=size(subjects,1);

if n_subjects>0
    filename=filelist(1).name;
    data = readcell(filename);
    % Obtain name and number of stimuli
    for i=1:size(data,2)
        if ~ismissing(data{5,i})
            id_stimuli(i) = data{5,i};
            names_stimuli(i) = string(data{4,i});
        end
    end
    n_stimuli = length(id_stimuli);
end


%% Import .txt files e compute per subject Elo rating

for i=1:n_stimuli
    db.(strcat('evolution_',names_stimuli(i),'_tot')) = [];
end

db.all_matches = [];  % needed for the aggregate Elo rating

for s = 1:length(subjects)

    filename=filelist(s).name;
    data = readcell(filename);

    matches = cell2mat(data(7:end, 1:3));
    db.all_matches = [db.all_matches; matches];
     

    % Initialize Elo scores
    k = 20;
    ELOS(1:n_stimuli) = struct('id', -1, 'name', '', 'elo', 1000,'pg', 0);
    
    for i = 1:n_stimuli
        ELOS(i).name = names_stimuli{i};
        ELOS(i).id = id_stimuli(i);
    end
    
    elo_evolution = elo_rating(ELOS, matches, n_stimuli, k);

    % Extract stimuli evolution
    for i=1:n_stimuli
        db.(strcat('evolution_',names_stimuli(i),'_tot')) = [db.(strcat('evolution_',names_stimuli(i),'_tot')); elo_evolution(:, i)'];
    end

end


%% Plot all subjects

if n_subjects>0
    fig0 = figure;
    for s = 1:n_subjects                                                                         
        subplot_height = ceil(n_subjects/3);
        subplot(subplot_height,3,s)
        for i=1:n_stimuli
            plot([0:1:size(matches,1)], db.(strcat('evolution_',names_stimuli(i),'_tot'))(s,:), 'LineWidth', 1,  'Color', color_map(i,:))
            hold on
        end
        title(subjects(s,1:3), 'Interpreter', 'none'); xlim([0 (size(matches,1)+1)]);
    end
    sgtitle('Per Subject Elo Ratings', 'FontSize', 14, 'Interpreter', 'none')
    
        
    fig0.WindowState = 'maximized';
    legend(sn, 'Orientation', 'horizontal', 'Location', 'best', 'Position', [0.416141894407728,0.030265011273335,0.2078125,0.025515210991168])
    
    if save_figures
        fig_filename = strcat(path_main, '\images\', 'per_subject_Elo_ranking');
        savefig(strcat(fig_filename, '.fig'))
        saveas(fig0, strcat(fig_filename, '.png'))
    end

%     close all
end





%% Aggregate Elo rating with total shuffle (all traces)
fig7 = figure();
set(gcf,'Units','centimeters');
set(gcf,'Position',[1 1 20 10]);

k = 20;

for idx=1:shuffle_repetitions

    all_matches_mixed=db.all_matches(randperm(n_subjects*size(matches,1)),:);

    ELOS(1:n_stimuli) = struct('id', -1, 'name', '', 'elo', 1000,'pg', 0);
    
    for i = 1:n_stimuli
        ELOS(i).name = names_stimuli(i);
        ELOS(i).id = id_stimuli(i);
    end
    
    elo_evolution = elo_rating(ELOS, all_matches_mixed, n_stimuli, k);
    
    % Extract stimuli evolution
    
    for i=1:n_stimuli
        plot([0:1:size(db.all_matches,1)], elo_evolution(:,i), 'LineWidth', 0.5, 'Color', color_map(i,:))
        hold on
    end


    % for mean weighted consistency index

    for j=1:n_subjects
        all_matches_partial=db.all_matches(1:j*90,:);
        all_matches_partial_mixed=db.all_matches(randperm(j*90),:);

        ELOS(1:n_stimuli) = struct('id', -1, 'name', '', 'elo', 1000,'pg', 0);
        
        for i = 1:n_stimuli
            ELOS(i).name = names_stimuli(i);
            ELOS(i).id = id_stimuli(i);
        end
        
        elo_evolution = elo_rating(ELOS, all_matches_partial_mixed, n_stimuli, k);

        cons_idx=0;
        cons_idx_weight=0;
    
    
        for i=1:size(all_matches_partial_mixed,1)
            if (all_matches_partial_mixed(i,1)<all_matches_partial_mixed(i,2) && all_matches_partial_mixed(i,3)==2) || (all_matches_partial_mixed(i,1)>all_matches_partial_mixed(i,2) && all_matches_partial_mixed(i,3)==1)
                cons_idx=cons_idx+abs(elo_evolution(i,all_matches_partial_mixed(i,1)+1) - elo_evolution(i,all_matches_partial_mixed(i,2)+1));
            end
            cons_idx_weight=cons_idx_weight+abs(elo_evolution(i,all_matches_partial_mixed(i,1)+1) - elo_evolution(i,all_matches_partial_mixed(i,2)+1));
        end
    
        cons_index(idx,j)=cons_idx/cons_idx_weight;

    end

end

fontsize=10;

title('Aggregate Elo Ranking',  'FontSize', fontsize, 'FontName', 'Calibri', 'Interpreter', 'none')

xlabel('Trial', 'FontSize', fontsize, 'FontName', 'Calibri'); ylabel('Elo Score', 'FontSize', fontsize, 'FontName', 'Calibri');
xt = (length(elo_evolution(:,1)) + 5) * ones(1, n_stimuli);
yt = [];
for i=1:n_stimuli
    yt = [yt elo_evolution(end,i)];
end

text(xt,yt,sn, 'FontSize', fontsize, 'FontName', 'Calibri')

% grid on
set(gca, ...
    'FontSize', fontsize, ...
    'FontName', 'Calibri', ...
    'XMinorTick', 'on', ...
    'YMinorTick', 'on', ...
    'Box', 'off');


ylim([400 1500]);

    % === EXPORT FIGURE ===
if save_figures
    fig_filename = strcat(path_main, '\images\', 'aggregate_Elo_all_traces');
    savefig(strcat(fig_filename,'.fig'))
    exportgraphics(gcf, strcat(fig_filename, '.eps'), 'ContentType', 'vector');   %EPS
    print(gcf, strcat(fig_filename, '.png'), '-dpng', '-r1000');  % PNG, 1000 DPI
    print(gcf, strcat(fig_filename, '.pdf'), '-dpdf');           % PDF

    % Save SVG if you have export capability (needs R2020a+ or export_fig toolbox)
    try
        saveas(gcf, strcat(fig_filename, '.svg'));
    catch
        warning('Could not save as SVG. Try using export_fig if needed.');
    end
end







%% Aggregate Elo rating with total shuffle (median&quartiles)


fig8 = figure;
set(gcf,'Units','centimeters');
set(gcf,'Position',[1 1 20 10]);

k = 20;

for i=1:n_stimuli
    db.(strcat('aggregated_evolution_',names_stimuli(i))) = [];
end

for idx=1:shuffle_repetitions

    all_matches_mixed=db.all_matches(randperm(n_subjects*size(matches,1)),:);

    ELOS(1:n_stimuli) = struct('id', -1, 'name', '', 'elo', 1000,'pg', 0);
    
    for i = 1:n_stimuli
        ELOS(i).name = names_stimuli{i};
        ELOS(i).id = id_stimuli(i);
    end
    
    elo_evolution = elo_rating(ELOS, all_matches_mixed, n_stimuli, k);
    
    % Extract stimuli evolution
    for i=1:n_stimuli
        db.(strcat('aggregated_evolution_',names_stimuli(i))) = [db.(strcat('aggregated_evolution_',names_stimuli(i))); elo_evolution(:, i)'];
    end

end

for i=1:n_stimuli
    db.(strcat('aggregated_median_',names_stimuli(i))) = median(db.(strcat('aggregated_evolution_',names_stimuli(i))));
end

for i=1:n_stimuli
    db.(strcat('aggregated_qrt_',names_stimuli(i))) = prctile(db.(strcat('aggregated_evolution_',names_stimuli(i))), [25 75], 1);
end

for i=1:n_stimuli
    db.(strcat('aggregated_std_',names_stimuli(i))) = std(db.(strcat('aggregated_evolution_',names_stimuli(i))));
end


highest_rate = max([db.aggregated_median_AAd(1,end); db.aggregated_median_AB(1,end); db.aggregated_median_GdB(1,end); db.aggregated_median_GB(1,end); db.aggregated_median_GC(1,end); db.aggregated_median_FC(1,end)]);
lowest_rate = min([db.aggregated_median_AAd(1,end); db.aggregated_median_AB(1,end); db.aggregated_median_GdB(1,end); db.aggregated_median_GB(1,end); db.aggregated_median_GC(1,end); db.aggregated_median_FC(1,end)]);
quality_index = ( highest_rate - lowest_rate ) / mean( [mean(db.aggregated_std_AAd(:)); mean(db.aggregated_std_AB(:)); mean(db.aggregated_std_GdB(:)); mean(db.aggregated_std_GB(:)); mean(db.aggregated_std_GC(:)); mean(db.aggregated_std_FC(:))] );

x = [0:1:size(db.all_matches,1)]; x2 = [x, fliplr(x)];
for i=1:n_stimuli
    inBetween = [db.(strcat('aggregated_qrt_',names_stimuli(i)))(2,:), fliplr(db.(strcat('aggregated_qrt_',names_stimuli(i)))(1,:))];
    fill(x2, inBetween, color_map(i,:), 'FaceAlpha', 0.1, 'LineStyle','none');
    hold on;
    plot([0:1:size(db.all_matches,1)], db.(strcat('aggregated_median_',names_stimuli(i))), 'LineWidth', 1.5, 'Color', color_map(i,:))
end


fontsize = 10;
title('Aggregate Elo Ranking', 'FontSize', fontsize, 'FontName', 'Calibri', 'Interpreter', 'none')

xlabel('Trial', 'FontSize', fontsize, 'FontName', 'Calibri'); ylabel('Elo Score', 'FontSize', fontsize, 'FontName', 'Calibri');
xt = (length(elo_evolution(:,1)) + 5) * ones(1, n_stimuli);
yt = [];
for i=1:n_stimuli
      yt = [yt db.(strcat('aggregated_median_',names_stimuli(i)))(end)];
end

text(xt,yt,sn,'FontSize', fontsize, 'FontName', 'Calibri')


ax = gca; % Get current axes
grid on;
grid minor;
% Set grid color to a light gray
ax.GridColor = [0.7 0.7 0.7]; % RGB between 0 and 1, here 0.7 is light gray
% Make the grid lines thinner and less opaque
ax.GridAlpha = 0.3; % Transparency (0 = fully transparent, 1 = fully opaque)
ax.LineWidth = 0.8; % Optional: reduce line width
ax.MinorGridLineStyle = '-';
ax.MinorGridColor = [0.85 0.85 0.85];
ax.MinorGridAlpha = 0.2;
ax.LineWidth = 0.5;

set(gca, ...
    'FontSize', fontsize, ...
    'FontName', 'Calibri', ...
    'XMinorTick', 'on', ...
    'YMinorTick', 'on', ...
    'Box', 'off');

ylim([400 1500]);

    % === EXPORT FIGURE ===
if save_figures
    fig_filename = strcat(path_main, '\images\', 'aggregate_Elo_median&qrt');
    savefig(strcat(fig_filename,'.fig'))
    exportgraphics(gcf, strcat(fig_filename, '.eps'), 'ContentType', 'vector');   %EPS
    print(gcf, strcat(fig_filename, '.png'), '-dpng', '-r1000');  % PNG, 1000 DPI
    print(gcf, strcat(fig_filename, '.pdf'), '-dpdf');           % PDF

    % Save SVG if you have export capability (needs R2020a+ or export_fig toolbox)
    try
        saveas(gcf, strcat(fig_filename, '.svg'));
    catch
        warning('Could not save as SVG. Try using export_fig if needed.');
    end
end


norm_rating=(yt'-min(yt'))/(max(yt')-min(yt'));


tot_risp1=sum(all_matches_mixed(:,3)==1)/size(all_matches_mixed,1);
tot_risp2=sum(all_matches_mixed(:,3)==2)/size(all_matches_mixed,1);
tot_risp0=sum(all_matches_mixed(:,3)==0)/size(all_matches_mixed,1);


%intra-subject consistency index

intra=zeros(n_subjects,15,3);

all_matches=db.all_matches;

for i=1:n_subjects
    for j=1:size(matches,1)
        % answer option 1
        intra(i,1,1)=intra(i,1,1)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==1));
        intra(i,2,1)=intra(i,2,1)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==1));
        intra(i,3,1)=intra(i,3,1)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==1));
        intra(i,4,1)=intra(i,4,1)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==1));
        intra(i,5,1)=intra(i,5,1)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==1));
        intra(i,6,1)=intra(i,6,1)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==1));
        intra(i,7,1)=intra(i,7,1)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==1));
        intra(i,8,1)=intra(i,8,1)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==1));
        intra(i,9,1)=intra(i,9,1)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==1));
        intra(i,10,1)=intra(i,10,1)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==1));
        intra(i,11,1)=intra(i,11,1)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==1));
        intra(i,12,1)=intra(i,12,1)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==1));
        intra(i,13,1)=intra(i,13,1)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==1));
        intra(i,14,1)=intra(i,14,1)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==1));
        intra(i,15,1)=intra(i,15,1)+sum((all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==2) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==1));

        % answer option 2
        intra(i,1,2)=intra(i,1,2)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==2));
        intra(i,2,2)=intra(i,2,2)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==2));
        intra(i,3,2)=intra(i,3,2)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==2));
        intra(i,4,2)=intra(i,4,2)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==2));
        intra(i,5,2)=intra(i,5,2)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==2));
        intra(i,6,2)=intra(i,6,2)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==2));
        intra(i,7,2)=intra(i,7,2)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==2));
        intra(i,8,2)=intra(i,8,2)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==2));
        intra(i,9,2)=intra(i,9,2)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==2));
        intra(i,10,2)=intra(i,10,2)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==2));
        intra(i,11,2)=intra(i,11,2)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==2));
        intra(i,12,2)=intra(i,12,2)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==2));
        intra(i,13,2)=intra(i,13,2)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==2));
        intra(i,14,2)=intra(i,14,2)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==2));
        intra(i,15,2)=intra(i,15,2)+sum((all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==1) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==2));

        % answer option 3
        intra(i,1,3)=intra(i,1,3)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==0));
        intra(i,2,3)=intra(i,2,3)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==0));
        intra(i,3,3)=intra(i,3,3)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==0));
        intra(i,4,3)=intra(i,4,3)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==0));
        intra(i,5,3)=intra(i,5,3)+sum((all_matches((i-1)*90+j,1)==0 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==0 && all_matches((i-1)*90+j,3)==0));
        intra(i,6,3)=intra(i,6,3)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==0));
        intra(i,7,3)=intra(i,7,3)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==0));
        intra(i,8,3)=intra(i,8,3)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==0));
        intra(i,9,3)=intra(i,9,3)+sum((all_matches((i-1)*90+j,1)==1 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==1 && all_matches((i-1)*90+j,3)==0));
        intra(i,10,3)=intra(i,10,3)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==0));
        intra(i,11,3)=intra(i,11,3)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==0));
        intra(i,12,3)=intra(i,12,3)+sum((all_matches((i-1)*90+j,1)==2 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==2 && all_matches((i-1)*90+j,3)==0));
        intra(i,13,3)=intra(i,13,3)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==0));
        intra(i,14,3)=intra(i,14,3)+sum((all_matches((i-1)*90+j,1)==3 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==3 && all_matches((i-1)*90+j,3)==0));
        intra(i,15,3)=intra(i,15,3)+sum((all_matches((i-1)*90+j,1)==4 && all_matches((i-1)*90+j,2)==5 && all_matches((i-1)*90+j,3)==0) || (all_matches((i-1)*90+j,1)==5 && all_matches((i-1)*90+j,2)==4 && all_matches((i-1)*90+j,3)==0));
    end
end

for i=1:n_subjects
    for j=1:15
        intra_total_intermediate(i,j)=max(intra(i,j,:));
    end
end

for i=1:n_subjects
    intra_total(i,1)=sum(intra_total_intermediate(i,:))/90;
end

intra_index=sum(intra_total(:))/n_subjects;




%inter-reliability index (or consistency index)

%weighted

inter_index=mean(cons_index(:,end));

%not weighted
inter1=0;
inter2=0;
inter3=0;
inter4=0;
inter5=0;
inter6=0;
inter7=0;
inter8=0;
inter9=0;
inter10=0;
inter11=0;
inter12=0;
inter13=0;
inter14=0;
inter15=0;


for i=1:size(all_matches_mixed,1)
    inter1=inter1+sum((all_matches_mixed(i,1)==0 && all_matches_mixed(i,2)==1 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==1 && all_matches_mixed(i,2)==0 && all_matches_mixed(i,3)==1));
    inter2=inter2+sum((all_matches_mixed(i,1)==0 && all_matches_mixed(i,2)==2 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==2 && all_matches_mixed(i,2)==0 && all_matches_mixed(i,3)==1));
    inter3=inter3+sum((all_matches_mixed(i,1)==0 && all_matches_mixed(i,2)==3 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==3 && all_matches_mixed(i,2)==0 && all_matches_mixed(i,3)==1));
    inter4=inter4+sum((all_matches_mixed(i,1)==0 && all_matches_mixed(i,2)==4 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==4 && all_matches_mixed(i,2)==0 && all_matches_mixed(i,3)==1));
    inter5=inter5+sum((all_matches_mixed(i,1)==0 && all_matches_mixed(i,2)==5 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==5 && all_matches_mixed(i,2)==0 && all_matches_mixed(i,3)==1));
    inter6=inter6+sum((all_matches_mixed(i,1)==1 && all_matches_mixed(i,2)==2 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==2 && all_matches_mixed(i,2)==1 && all_matches_mixed(i,3)==1));
    inter7=inter7+sum((all_matches_mixed(i,1)==1 && all_matches_mixed(i,2)==3 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==3 && all_matches_mixed(i,2)==1 && all_matches_mixed(i,3)==1));
    inter8=inter8+sum((all_matches_mixed(i,1)==1 && all_matches_mixed(i,2)==4 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==4 && all_matches_mixed(i,2)==1 && all_matches_mixed(i,3)==1));
    inter9=inter9+sum((all_matches_mixed(i,1)==1 && all_matches_mixed(i,2)==5 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==5 && all_matches_mixed(i,2)==1 && all_matches_mixed(i,3)==1));
    inter10=inter10+sum((all_matches_mixed(i,1)==2 && all_matches_mixed(i,2)==3 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==3 && all_matches_mixed(i,2)==2 && all_matches_mixed(i,3)==1));
    inter11=inter11+sum((all_matches_mixed(i,1)==2 && all_matches_mixed(i,2)==4 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==4 && all_matches_mixed(i,2)==2 && all_matches_mixed(i,3)==1));
    inter12=inter12+sum((all_matches_mixed(i,1)==2 && all_matches_mixed(i,2)==5 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==5 && all_matches_mixed(i,2)==2 && all_matches_mixed(i,3)==1));
    inter13=inter13+sum((all_matches_mixed(i,1)==3 && all_matches_mixed(i,2)==4 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==4 && all_matches_mixed(i,2)==3 && all_matches_mixed(i,3)==1));
    inter14=inter14+sum((all_matches_mixed(i,1)==3 && all_matches_mixed(i,2)==5 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==5 && all_matches_mixed(i,2)==3 && all_matches_mixed(i,3)==1));
    inter15=inter15+sum((all_matches_mixed(i,1)==4 && all_matches_mixed(i,2)==5 && all_matches_mixed(i,3)==2) || (all_matches_mixed(i,1)==5 && all_matches_mixed(i,2)==4 && all_matches_mixed(i,3)==1));
end

inter_index=(inter1+inter2+inter3+inter4+inter5+inter6+inter7+inter8+inter9+inter10+inter11+inter12+inter13+inter14+inter15)/size(all_matches_mixed,1);



% we can track the conistency index with the growth of the involved
% subjects (i.e. the total answers). This gives an indication on the 
% subjects needed.
figure();
set(gcf,'Units','centimeters');
set(gcf,'Position',[1 1 20 8]);
curve=[];

fontsize = 10;
title('Mean weighted consistency index', 'FontSize', fontsize, 'FontName', 'Calibri', 'Interpreter', 'none')

qrt=prctile(cons_index, [25 75], 1);
curve(1,:) = median(cons_index) - qrt(1,:);
curve(2,:) = - median(cons_index) + qrt(1,:);
plot([1:1:n_subjects], median(cons_index), 'LineWidth', 1,'Color','#777777');
hold on
errorbar([1:1:n_subjects], median(cons_index), curve(1,:), curve(2,:) , 's', 'MarkerSize', 4, 'LineWidth', 0.8, 'Color','black');
hold on
xlabel('Number of raters (subjects)', 'FontSize', fontsize, 'FontName', 'Calibri'); ylabel('Weighted consistency index', 'FontSize', fontsize, 'FontName', 'Calibri');
xticks([0:n_subjects]);

ax = gca; % Get current axes
grid on

% Turn on minor grid
ax.YMinorGrid = 'on';
% Set grid color to a light gray
ax.GridColor = [0.7 0.7 0.7]; % RGB between 0 and 1, here 0.7 is light gray
% Make the grid lines thinner and less opaque
ax.GridAlpha = 0.3; % Transparency (0 = fully transparent, 1 = fully opaque)
ax.LineWidth = 0.8; % Optional: reduce line width
ax.MinorGridLineStyle = '-';
ax.MinorGridColor = [0.85 0.85 0.85];
ax.MinorGridAlpha = 0.2;
ax.LineWidth = 0.5;

set(gca, ...
    'FontSize', fontsize, ...
    'FontName', 'Calibri', ...
    'XMinorTick', 'off', ...
    'YMinorTick', 'on', ...
    'Box', 'off');


    % === EXPORT FIGURE ===
if save_figures
    fig_filename = strcat(path_main, '\images\', 'mean_weighted_consitency_index');
    savefig(strcat(fig_filename,'.fig'))
    exportgraphics(gcf, strcat(fig_filename, '.eps'), 'ContentType', 'vector');   %EPS
    print(gcf, strcat(fig_filename, '.png'), '-dpng', '-r1000');  % PNG, 1000 DPI
    print(gcf, strcat(fig_filename, '.pdf'), '-dpdf');           % PDF

    % Save SVG if you have export capability (needs R2020a+ or export_fig toolbox)
    try
        saveas(gcf, strcat(fig_filename, '.svg'));
    catch
        warning('Could not save as SVG. Try using export_fig if needed.');
    end
end


%JB test
for i=1:n_stimuli
    i
    [H,P,JBSTAT,CRITVAL]=jbtest(db.(strcat('aggregated_evolution_',names_stimuli(i)))(:,end),0.05,0.001)
end



elo_results=[];
for i=1:n_stimuli
    elo_results=[elo_results db.(strcat('aggregated_evolution_',names_stimuli(i)))(:,end)];
end

% 1-way ANOVA
[p,t,stats] = anova1(elo_results,names_stimuli)
set(gcf,'Units','centimeters');
set(gcf,'Position',[1 1 20 12]);



figure();
[c,m,h,gnames] = multcompare(stats)




%% distribution boxplot
figure;

set(gcf,'Units','centimeters');
set(gcf,'Position',[1 1 20 12]);

fontsize = 10;


boxColors = [
    0.5 0.5 0.6;  % custom color 1
];


h = boxplot(elo_results,names_stimuli, 'Widths', 0.5,'BoxStyle','outline','OutlierSize',4, 'Notch','off');
title('Elo score distributions', 'FontSize', fontsize, 'FontName', 'Calibri', 'Interpreter', 'none')
% set(gca, 'LooseInset', max(get(gca,'TightInset'), 0.02))

%grid on
set(gca, ...
    'FontSize', fontsize, ...
    'FontName', 'Calibri', ...
    'XMinorTick', 'off', ...
    'YMinorTick', 'on', ...
    'Box', 'off');

% color_map = [ 0.0000, 0.2682, 0.4446;  % Darker blue
%     0.2964, 0.1104, 0.3336;  % Darker purple
%     0.3810, 0.0468, 0.1104;  % Darker red
%     0.6000, 0.2460, 0.0960;  % Darker orange
%     0.5574, 0.4164, 0.0750;  % Darker yellow
%     0.2796, 0.4044, 0.1128]; % Darker green

color_map_reversed = color_map(end:-1:1, :);



% ===========================
% Coloring each box
% ===========================
patchHandles = findobj(h, 'Tag', 'Box');
for i = 1:length(patchHandles)
    patchColor = color_map_reversed(mod(length(patchHandles)-i, size(color_map_reversed,1))+1,:);
    patch(get(patchHandles(i),'XData'), get(patchHandles(i),'YData'), patchColor, ...
        'FaceAlpha', 0.2, 'EdgeColor', patchColor, 'LineWidth', 0.8);
end
w = findobj(gca, 'Tag', 'Whisker');  % Whiskers
m = findobj(gca, 'Tag', 'Median');   % Median lines
o = findobj(gca, 'Tag', 'Outliers'); % Outlier points
set(w, 'Color', boxColors);
set(m, 'Color', boxColors); 
set(o, 'MarkerEdgeColor', boxColors, 'Marker', '*');

hold on; % Enable holding on the plot

% Define positions for the boxes

xCenters = 1:6;
spread = 0.1; % Adjust this value to control point spread

% Plot individual points
scatter(xCenters(1) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,1), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);
scatter(xCenters(2) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,2), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);
scatter(xCenters(3) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,3), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);
scatter(xCenters(4) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,4), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);
scatter(xCenters(5) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,5), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);
scatter(xCenters(6) + rand(size(elo_results,1),1)*spread - (spread/2) + 0.38, elo_results(:,6), 2, 'o', 'filled', 'MarkerFaceColor', boxColors, 'MarkerEdgeColor', boxColors);

xlabel('Sound', 'FontSize', fontsize, 'FontName', 'Calibri'); ylabel('Elo Score', 'FontSize', fontsize, 'FontName', 'Calibri');
ylim([400 1500]);

hold off;



    % === EXPORT FIGURE ===
if save_figures
    fig_filename = strcat(path_main, '\images\', 'distribution_boxplots');
    savefig(strcat(fig_filename,'.fig'))
    exportgraphics(gcf, strcat(fig_filename, '.eps'), 'ContentType', 'vector');   %EPS
    print(gcf, strcat(fig_filename, '.png'), '-dpng', '-r1000');  % PNG, 1000 DPI
    print(gcf, strcat(fig_filename, '.pdf'), '-dpdf');           % PDF

    % Save SVG if you have export capability (needs R2020a+ or export_fig toolbox)
    try
        saveas(gcf, strcat(fig_filename, '.svg'));
    catch
        warning('Could not save as SVG. Try using export_fig if needed.');
    end
end

