2;
function output = get_output(entries, weights, neurons_per_layer, activation_func)
    m = 0;
    for i = 2:length(neurons_per_layer)
        m = m + 1;
        layer_entry{m} = [-1, zeros(1, neurons_per_layer(i-1))];
    end
    M = m;
    i = 1;
    for entry = entries
            layer_entry{1}(2:end) = [entry];
        for m = 2:M
                layer_entry{m}(2:end) = activation_func(weights{m-1} * layer_entry{m-1}');
        end
        output(i) = (weights{M} * layer_entry{M}');
        i = i + 1;
    end   
end

function [weights,output,error_per_iteration] = multilayer_perceptron_learn(entries, expected_output, neurons_per_layer, activation_func, activation_der,
                                    learning_factor=.5, max_iterations=1000, tolerance=1e-5, dbug=false)
    %number of entries
    n = length(entries(1,:));

    %number of layers
    m = 0;

    %setup
    for i = 2:length(neurons_per_layer)
        m = m + 1;
        %weights{m} = (2*(rand(neurons_per_layer(i), neurons_per_layer(i-1)+1) .- 0.5))./100;
        weights{m} = (rand(neurons_per_layer(i), neurons_per_layer(i-1)+1) .- 0.5)./(neurons_per_layer(i-1));
        layer_entry{m} = [-1, zeros(1, neurons_per_layer(i-1))];
    	h{m} = [-1 ,zeros(1, neurons_per_layer(i-1))];
    end
    %last layer
    M = m;

    for iteration = 1:max_iterations
    tic; 
	%select random entry
        for index = randperm(n);
            %get layers output 
            layer_entry{1}(2:end) = entries(:, index);
            for m = 2:M
		        h{m-1} = weights{m-1} * layer_entry{m-1}';
                layer_entry{m}(2:end) = activation_func(h{m-1});
            end
            if dbug 
                layer_entry
                fflush(1);
	        end
            h{M} = weights{M} * layer_entry{M}';
            
            %no linear
            %output(index) = activation_func(h{M});
            %get errors
            %d{M} = activation_der(h{M})*(expected_output(index) - output(index));
            
            %linear
            output(index) = h{M};
            %h{M};
            %get errors
            d{M} = (expected_output(index) - output(index));
            %d{M};
            
            for i = M-1:-1:1
                d{i} = (activation_der(h{i})' .* (d{i+1} * weights{i+1}(:,2:end)));
            end
            %correct weights
            d;
            for i = 1:M
                delta_w = learning_factor * d{i}' * layer_entry{i};
                weights{i} = weights{i} + delta_w;
            end
        end
        %get iteration error
        error_per_iteration(iteration) = sum((expected_output - output).^2)/n;
        [error_per_iteration(iteration),iteration,toc]
        fflush(1);
        if error_per_iteration(iteration) <= tolerance
            return
        end
        if error_per_iteration(iteration) <= 5e-4
            learning_factor = .02;
        end
        if error_per_iteration(iteration) <= 4e-4
            learning_factor = .01;
        end
    end

end

