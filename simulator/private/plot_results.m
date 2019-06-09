function plot_results(obj)
T_ode45 = obj.history.T_ode45;
Force_Moment_log = obj.history.Force_Moment_log;
X_ode45 = obj.history.X_ode45;
F_Th_Opt = obj.history.F_Th_Opt;
Force_Moment_log_req = obj.history.Force_Moment_log_req;

%% calculate fuel consumption
Thr_force = max(F_Th_Opt(:));
FC_history = cumsum(F_Th_Opt)/Thr_force;
FC_total = sum(FC_history(end,:));
fprintf('Total Thruster-On Time (Fuel Consumption) = %.3f seconds\n', FC_total*obj.h)

%% calculate Quadratic Cost function
try %#ok<*TRYNC>
    Qx = obj.controller_params.Qx;
    Qv = obj.controller_params.Qv;
    Qt = obj.controller_params.Qt;
    Qw = obj.controller_params.Qw;
    R = obj.controller_params.R;
    
    X = obj.history.X_ode45;
    U = obj.history.F_Th_Opt;
    costx = sum( sum( X(:,1:3).^2 ))*Qx;
    costv = sum( sum( X(:,4:6).^2 ))*Qv;
    costu = sum( U(:))*R;
    total_cost =  costx + costv + costu;
    
    fprintf('costX: %.2g | costV: %.2g | costU: %.2g, Total = %.3g\n',...
        costx,costv,costu,total_cost)
end
%% plot path over control surface
% theta as angles
[theta1q2a,theta2q2a,theta3q2a] = quat2angle(X_ode45(:,10:-1:7));
% single rotation thetas as  controller 'sees' them:
theta1 = obj.history.Theta_history(:,1)*180/pi;      
theta2 = obj.history.Theta_history(:,2)*180/pi; 
theta3 = obj.history.Theta_history(:,3)*180/pi; 
          
diff_t1 = [0; diff(theta1)]/obj.h;
diff_t2 = [0; diff(theta2)]/obj.h;
diff_t3 = [0; diff(theta3)]/obj.h;
diff_t1(abs(diff_t1) > 100) = NaN;
diff_t2(abs(diff_t2) > 100) = NaN;
diff_t3(abs(diff_t3) > 100) = NaN;

if(0) %skip
    
    x3 = X_ode45(:,3);
    v3 = X_ode45(:,6);
    F3 = Force_Moment_log(:,3)*obj.Mass;
    t1 = theta1;
    w1 = X_ode45(:,11);
    M1 = Force_Moment_log(:,4);
    if(~strcmp(obj.controller_params.type,'PID'))
        [axF,axM] = test_surface(obj.current_controller);
        axes(axF.Parent)
        % colormap('winter')
        hold on, plot3(x3,v3,F3,'m:', 'LineWidth',2.0);
        
        axes(axM.Parent)
        % colormap('winter')
        hold on, plot3(t1,w1,M1,'m:', 'LineWidth',2.0);
    end
end
%% plot Thruster Firings
        ylim_thr = [-.15 .15];
        pos_fig_thruster = [7.4000   61.8000  538.4000  712.8000];
        figure('Name','Thruster Firings','Position',pos_fig_thruster,...
    'color', 'white')
        subplot(4,3,1)
        plot(T_ode45, F_Th_Opt(:,1))
        title('#0 (x)')
        grid on
        ylim(ylim_thr)
        % xlim([-0.05 Inf])
        
        subplot(4,3,2)
        plot(T_ode45, F_Th_Opt(:,3))
        title('#2 (y)')    
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,3)
        plot(T_ode45, F_Th_Opt(:,5))
        title('#4 (z)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,4)
        plot(T_ode45, F_Th_Opt(:,2))
        title('#1 (x)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,5)
        plot(T_ode45, F_Th_Opt(:,4))
        title('#3 (y)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,6)
        plot(T_ode45, F_Th_Opt(:,6))
        title('#5 (z)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,7)
        plot(T_ode45, F_Th_Opt(:,7))
        title('#6 (-x)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,8)
        plot(T_ode45, F_Th_Opt(:,9))
        title('#8 (-y)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,9)
        plot(T_ode45, F_Th_Opt(:,11))
        title('#10 (-z)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,10)
        plot(T_ode45, F_Th_Opt(:,8))
        title('#7 (-x)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,11)
        plot(T_ode45, F_Th_Opt(:,10))
        title('#9 (-y)')
        grid on
        ylim(ylim_thr)
        
        subplot(4,3,12)
        plot(T_ode45, F_Th_Opt(:,12))
        title('#11 (-z)')
        grid on
        ylim(ylim_thr)
  
% 
        %plot Forces and Moments, compare required Force-Moments vs actual Force-Moments
        ylim_F = [-0.3 0.3]/obj.Mass;
        ylim_M = [-0.3 0.3]*obj.T_dist;
        pos_fig_FM = [547.4000  449.8000  518.4000  326.4000];
        figure('Name','Forces and Moments','Position',pos_fig_FM,...
    'color', 'white')
        
        subplot(3,2,1)
        plot(T_ode45, Force_Moment_log(:,1))
        title('acceleration x-direction')
        grid on
        ylim(ylim_F)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,1),'r')
        legend('actual','required')

        
        subplot(3,2,3)
        plot(T_ode45, Force_Moment_log(:,2))
        title('acceleration y-direction')
        grid on
        ylim(ylim_F)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,2),'r')
        legend('actual','required')
        
        subplot(3,2,5)
        plot(T_ode45, Force_Moment_log(:,3))
        title('acceleration z-direction')
        grid on
        ylim(ylim_F)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,3),'r')
        legend('actual','required')
        
        subplot(3,2,2)
        plot(T_ode45, Force_Moment_log(:,4))
        title('Moment x-direction')
        grid on
        ylim(ylim_M)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,4),'r')
        legend('actual','required')
        
        subplot(3,2,4)
        plot(T_ode45, Force_Moment_log(:,5))
        title('Moment y-direction')
        grid on
        ylim(ylim_M)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,5),'r')
        legend('actual','required')
        
        subplot(3,2,6)
        plot(T_ode45, Force_Moment_log(:,6))
        title('Moment z-direction')
        grid on
        ylim(ylim_M)
        hold on
        plot(T_ode45, Force_Moment_log_req(:,6),'r')
        legend('actual','required')
        
        % plot states - pos
        pos_fig_x = [543.4000   49.0000  518.4000  326.4000];
        figure('Name','states - position','Position',pos_fig_x,...
    'color', 'white')
        title('states - position (m)')
        plot(T_ode45, X_ode45(:,1))
        hold on
        plot(T_ode45, X_ode45(:,2))
        plot(T_ode45, X_ode45(:,3))
        grid on
        legend('x1','x2','x3')
        xlabel('time (s)')
        ylabel('position (m)')
        
        % plot states - v
        pos_fig_v = [954.6000  446.6000  518.4000  326.4000];
        figure('Name','states - velocity','Position',pos_fig_v,...
    'color', 'white')
        title('states - velocity (m/s)')

        plot(T_ode45, X_ode45(:,4))
        hold on
        plot(T_ode45, X_ode45(:,5))
        plot(T_ode45, X_ode45(:,6))
        grid on
        legend('v1','v2','v3')
        
        xlabel('time (s)')
        ylabel('velocity (m/s)')
        
%          % plot states - q
%         pos_fig_q = [973.0000  218.6000  518.4000  326.4000];
%         figure('Name','states - quaternions','Position',pos_fig_q,...
%     'color', 'white')
%         title('states - quaternions')
% 
%         plot(T_ode45, X_ode45(:,7))
%         hold on
%         plot(T_ode45, X_ode45(:,8))
%         plot(T_ode45, X_ode45(:,9))
%         plot(T_ode45, X_ode45(:,10))
%         grid on
%         legend('q1','q2','q3','q4')
        
        
%          % plot states - angles
%         pos_fig_a = [973.0000  218.6000  518.4000  326.4000]+10;
%         figure('Name','states - angles','Position',pos_fig_a,...
%     'color', 'white')
%         
%         plot(T_ode45, theta1)
%         hold on
%         plot(T_ode45, theta2)
%         plot(T_ode45, theta3)
%         grid on
%             %plot w2 cumulative sum
%             w2 =  X_ode45(:,12)*180/pi;
% %             cumsum_diff_t2 = cumsum(diff_t2)/(length(diff_t2)-1)*180;%  theta2 =
% %            t2_from_intw2 = cumsum(w2)/(length(w2)-1)*180;
%             t2_from_trapz_w2 = cumtrapz(T_ode45,w2);
%         plot(T_ode45,t2_from_trapz_w2,'--r')
%         
%         legend('\theta_1','\theta_2','\theta_3','integral(w2)')
               
%          % plot states - angles from 3 quaternions conversion
%         pos_fig_a = [973.0000+1  218.6000+1  518.4000+1  326.4000+1]-5;
%         figure('Name','states - quat2angles','Position',pos_fig_a,...
%     'color', 'white')
%         
%         plot(T_ode45, theta1q2a*180/pi)
%         hold on
%         plot(T_ode45, theta2q2a*180/pi)
%         plot(T_ode45, theta3q2a*180/pi)
%         grid on
%         legend('\theta_1','\theta_2','\theta_3')
%                
        
       
        % plot states - w
        pos_fig_w = [956.2000   47.4000  518.4000  326.4000];
        figure('Name','states - rotational speeds','Position',pos_fig_w,...
    'color', 'white')
        
        plot(T_ode45, X_ode45(:,11)*180/pi)
        title('states - rotational speeds (deg/sec)')

        hold on
        
        plot(T_ode45, X_ode45(:,12)*180/pi)
        plot(T_ode45, X_ode45(:,13)*180/pi)
        grid on
        legend('w1','w2','w3')
        
        xlabel('time (s)')
        ylabel('rotational speed (deg/s)')
        
        
%         id = abs(t2_from_trapz_w2) > 180;
%         t2_new = theta2;
%         t2_new(id) = -t2_new(id);
%         figure
%         plot(T_ode45,t2_new)
        
        figure('Name','controller angles','Position',pos_fig_w,...
    'color', 'white')
        title('Controller Angles input')

        plot(T_ode45,obj.history.Theta_history(:,1)*180/pi);
        hold on
        plot(T_ode45,obj.history.Theta_history(:,2)*180/pi);
        plot(T_ode45,obj.history.Theta_history(:,3)*180/pi);
        grid on
        legend('\theta_1','\theta_2','\theta_3')
%         
%         [X,Y,Z] = quat_eul(X_ode45(:,10:-1:7));
%         figure('Name','angles quat eul','Position',pos_fig_w,...
%     'color', 'white')
%         title('Quat Eul conv')
% 
%         plot(T_ode45,X);
%         hold on
%         plot(T_ode45,Y);
%         plot(T_ode45,Z);
%         grid on
%         legend('\phi','\theta','sai')
        
%         
%         plot diff theta
        figure('Name','theta diff','Position',pos_fig_w+3,...
    'color', 'white')
        
        plot(T_ode45, diff_t1,'-')
        title('states - rotational speeds (deg/sec)')

        hold on
        plot(T_ode45, diff_t2,'-')
        plot(T_ode45, diff_t3,'-')
        grid on
        legend('diff-t1','diff-t2','diff-t3')
        
        xlabel('time (s)')
        ylabel('(deg/s)')
%         
        eul = quat2eul(X_ode45(:,10:-1:7));
        
        figure('Name','Euler angles','Position',pos_fig_w+3,...
    'color', 'white')
        
        plot(T_ode45, eul(:,1)*180/pi,'-')
        title('quat to eul')

        hold on
        plot(T_ode45, eul(:,2)*180/pi,'-')
        plot(T_ode45, eul(:,3)*180/pi,'-')
        grid on
        legend('\phi','\theta','\psi')
        
        xlabel('time (s)')
        ylabel('(deg)')
        
end