function [elo_evolution] = elo_rating(ELOS, matches, n_stimoli, k)

        % Compute elo score evolution with matches
        elo_evolution = 1e3*ones(1,n_stimoli);
        ok = true;

        for i = 1:size(matches,1)   
            match = matches(i,:);
        
            p1 = find_index(ELOS, match(1), n_stimoli);
            p2 = find_index(ELOS, match(2), n_stimoli);
            result = match(3);
            
            % Increment counter
            ELOS(p1).pg = ELOS(p1).pg + 1;
            ELOS(p2).pg = ELOS(p2).pg + 1;
            
            % Compute winning probabilities
            E1 = 1/(1 + 10^( (ELOS(p2).elo - ELOS(p1).elo)/400 ));
            E2 = 1/(1 + 10^( (ELOS(p1).elo - ELOS(p2).elo)/400 ));
            
            % Update ELOS
            if result == 0
                % Draw
                ELOS(p1).elo = ELOS(p1).elo + k*(0.5 - E1);
                ELOS(p2).elo = ELOS(p2).elo + k*(0.5 - E2);
            elseif result == 1
                % 1 Wins
                ELOS(p1).elo = ELOS(p1).elo + k*(1 - E1);
                ELOS(p2).elo = ELOS(p2).elo + k*(0 - E2);
            elseif result == 2
                % 2 Wins
                ELOS(p1).elo = ELOS(p1).elo + k*(0 - E1);
                ELOS(p2).elo = ELOS(p2).elo + k*(1 - E2);
            end
            
            status = zeros(1,n_stimoli);

            for j = 1:n_stimoli
                status(j)=ELOS(j).elo;
            end

            elo_evolution = [elo_evolution; status];
        end
end
