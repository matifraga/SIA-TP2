2;
function output = get_output(entry,weights,activation_func)
    output = activation_func(weights * entry);
end

function [weights,output,error] = multilayer_perceptron_learn(entries, expected_output, neurons_per_layer, activation_func, activation_der,
                                    learning_factor=.5, max_iterations=1000, tolerance=1e-5)
    n = length(entries(:, 1));
    m = 0;
    for i = 2:length(neurons_per_layer)
        m = m + 1;
        weights{m} = rand(neurons_per_layer(i), neurons_per_layer(i-1)+1) .- 0.5;
        layer_entry{m} = [-1, zeros(1, neurons_per_layer(i-1))];
    end
    M = m;
    for iteration = 1:max_iterations
        for index = randperm(2^n); 
                layer_entry{1}(2:end) = entries(:, index);
            for m = 2:M
                layer_entry{m}(2:end) = activation_func(weights{m-1} * layer_entry{m-1}');
            end
            layer_entry;
            output(index) = activation_func(weights{M} * layer_entry{M}');
            output(index);
            d{M} = activation_der(weights{M}*layer_entry{M}')*(expected_output(index) - output(index));
            for i = M-1:-1:1
                d{i} = (weights{i+1}(:,2:end)*d{i+1}' * activation_der(weights{i}*layer_entry{i}'));
            end
            d;
            weights;
            for i = 1:M
                delta_w = learning_factor * layer_entry{i}'*d{i};
                weights{i} = weights{i} + delta_w';
            end
        end
        error(iteration) = sum(abs(expected_output - output));
        if error <= tolerance
            return
        end
    end

end
