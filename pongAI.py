#PONG pygame

import random
import pygame, sys
from pygame.locals import *

pygame.init()
fps = pygame.time.Clock()

#colors
WHITE = (255,255,255)
RED = (255,0,0)
GREEN = (0,255,0)
BLACK = (0,0,0)
#globals
WIDTH = 1000
HEIGHT = 600       
BALL_RADIUS = 10
PAD_WIDTH = 8
PAD_HEIGHT = 80
HALF_PAD_WIDTH = PAD_WIDTH // 2
HALF_PAD_HEIGHT = PAD_HEIGHT // 2
ball_num = 10
colorlist = [RED] * ball_num
ball_pos = [[0,0]] * ball_num
ball_vel = [[0,0]] * ball_num
paddle1_vel = [0, 0]
paddle2_vel = [0, 0]
paddle1_pos = [[0, 0], [0, 0]]
paddle2_pos = [[0, 0], [0, 0]]
l_score = 0
r_score = 0

#canvas declaration
window = pygame.display.set_mode((WIDTH, HEIGHT), 0, 32)
pygame.display.set_caption('Hello World')
reward = 0
# helper function that spawns a ball, returns a position vector and a velocity vector
# if right is True, spawn to the right, else spawn to the left
def ball_init(id):
    global ball_pos, ball_vel # these are vectors stored as lists
    ball_pos[id] = [WIDTH//2,HEIGHT//2]
    horz = random.randrange(2,4)
    vert = random.randrange(-3,3)
    if vert == 0:
        vert = vert + 1
    colorlist[id] = (random.randrange(0,255),random.randrange(0,255),random.randrange(0,255))
    if random.randrange(0,2) == 0:
        horz = - horz
        
    ball_vel[id] = [horz,-vert]

# define event handlers
def init():
    global paddle1_pos, paddle2_pos, paddle1_vel, paddle2_vel,l_score,r_score  # these are floats
    global score1, score2  # these are ints
    paddle1_pos[0] = [HALF_PAD_WIDTH - 1,HEIGHT//2]
    paddle2_pos[0] = [WIDTH +1 - HALF_PAD_WIDTH,HEIGHT//2]
    paddle1_pos[1] = [HALF_PAD_WIDTH - 1 + 160,HEIGHT//2]
    paddle2_pos[1] = [WIDTH +1 - HALF_PAD_WIDTH - 160,HEIGHT//2]
    l_score = 0
    r_score = 0
    for i in range(ball_num):
        ball_init(i)


#draw function of canvas
def draw(canvas):
    global paddle1_pos, paddle2_pos, ball_pos, ball_vel, l_score, r_score
    global reward
    canvas.fill(BLACK)
    pygame.draw.line(canvas, WHITE, [WIDTH // 2, 0],[WIDTH // 2, HEIGHT], 1)
    pygame.draw.line(canvas, WHITE, [PAD_WIDTH, 0],[PAD_WIDTH, HEIGHT], 1)
    pygame.draw.line(canvas, WHITE, [WIDTH - PAD_WIDTH, 0],[WIDTH - PAD_WIDTH, HEIGHT], 1)
    pygame.draw.circle(canvas, WHITE, [WIDTH//2, HEIGHT//2], 70, 1)

    # update paddle's vertical position, keep paddle on the screen
    if paddle1_pos[0][1] > HALF_PAD_HEIGHT and paddle1_pos[0][1] < HEIGHT - HALF_PAD_HEIGHT:
        paddle1_pos[0][1] += paddle1_vel[0]
    elif paddle1_pos[0][1] <= HALF_PAD_HEIGHT and paddle1_vel[0] > 0:
        paddle1_pos[0][1] += paddle1_vel[0]
    elif paddle1_pos[0][1] >= HEIGHT - HALF_PAD_HEIGHT and paddle1_vel[0] < 0:
        paddle1_pos[0][1] += paddle1_vel[0]

    if paddle1_pos[1][1] > HALF_PAD_HEIGHT and paddle1_pos[1][1] < HEIGHT - HALF_PAD_HEIGHT:
        paddle1_pos[1][1] += paddle1_vel[1]
    elif paddle1_pos[1][1] <= HALF_PAD_HEIGHT and paddle1_vel[1] > 0:
        paddle1_pos[1][1] += paddle1_vel[1]
    elif paddle1_pos[1][1] >= HEIGHT - HALF_PAD_HEIGHT and paddle1_vel[1] < 0:
        paddle1_pos[1][1] += paddle1_vel[1]
    
    if paddle2_pos[0][1] > HALF_PAD_HEIGHT and paddle2_pos[0][1] < HEIGHT - HALF_PAD_HEIGHT:
        paddle2_pos[0][1] += paddle2_vel[0]
    elif paddle2_pos[0][1] <= HALF_PAD_HEIGHT and paddle2_vel[0] > 0:
        paddle2_pos[0][1] += paddle2_vel[0]
    elif paddle2_pos[0][1] >= HEIGHT - HALF_PAD_HEIGHT and paddle2_vel[0] < 0:
        paddle2_pos[0][1] += paddle2_vel[0]

    if paddle2_pos[1][1] > HALF_PAD_HEIGHT and paddle2_pos[1][1] < HEIGHT - HALF_PAD_HEIGHT:
        paddle2_pos[1][1] += paddle2_vel[1]
    elif paddle2_pos[1][1] <= HALF_PAD_HEIGHT and paddle2_vel[1] > 0:
        paddle2_pos[1][1] += paddle2_vel[1]
    elif paddle2_pos[1][1] >= HEIGHT - HALF_PAD_HEIGHT and paddle2_vel[1] < 0:
        paddle2_pos[1][1] += paddle2_vel[1]

    #update ball
    for i in range(ball_num):
        ball_pos[i][0] += int(ball_vel[i][0])
        ball_pos[i][1] += int(ball_vel[i][1])

    #draw paddles and ball
    # pygame.draw.circle(canvas, RED, ball_pos, 20, 0)
    for i in range(ball_num):
        pygame.draw.rect(canvas, colorlist[i], [ball_pos[i][0]-BALL_RADIUS, ball_pos[i][1]-BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2], 2)
    pygame.draw.polygon(canvas, GREEN, [[paddle1_pos[0][0] - HALF_PAD_WIDTH, paddle1_pos[0][1] - HALF_PAD_HEIGHT], [paddle1_pos[0][0] - HALF_PAD_WIDTH, paddle1_pos[0][1] + HALF_PAD_HEIGHT], [paddle1_pos[0][0] + HALF_PAD_WIDTH, paddle1_pos[0][1] + HALF_PAD_HEIGHT], [paddle1_pos[0][0] + HALF_PAD_WIDTH, paddle1_pos[0][1] - HALF_PAD_HEIGHT]], 0)
    pygame.draw.polygon(canvas, GREEN, [[paddle2_pos[0][0] - HALF_PAD_WIDTH, paddle2_pos[0][1] - HALF_PAD_HEIGHT], [paddle2_pos[0][0] - HALF_PAD_WIDTH, paddle2_pos[0][1] + HALF_PAD_HEIGHT], [paddle2_pos[0][0] + HALF_PAD_WIDTH, paddle2_pos[0][1] + HALF_PAD_HEIGHT], [paddle2_pos[0][0] + HALF_PAD_WIDTH, paddle2_pos[0][1] - HALF_PAD_HEIGHT]], 0)
    pygame.draw.polygon(canvas, GREEN, [[paddle1_pos[1][0] - HALF_PAD_WIDTH, paddle1_pos[1][1] - HALF_PAD_HEIGHT], [paddle1_pos[1][0] - HALF_PAD_WIDTH, paddle1_pos[1][1] + HALF_PAD_HEIGHT], [paddle1_pos[1][0] + HALF_PAD_WIDTH, paddle1_pos[1][1] + HALF_PAD_HEIGHT], [paddle1_pos[1][0] + HALF_PAD_WIDTH, paddle1_pos[1][1] - HALF_PAD_HEIGHT]], 0)
    pygame.draw.polygon(canvas, GREEN, [[paddle2_pos[1][0] - HALF_PAD_WIDTH, paddle2_pos[1][1] - HALF_PAD_HEIGHT], [paddle2_pos[1][0] - HALF_PAD_WIDTH, paddle2_pos[1][1] + HALF_PAD_HEIGHT], [paddle2_pos[1][0] + HALF_PAD_WIDTH, paddle2_pos[1][1] + HALF_PAD_HEIGHT], [paddle2_pos[1][0] + HALF_PAD_WIDTH, paddle2_pos[1][1] - HALF_PAD_HEIGHT]], 0)
    #ball collision check on top and bottom walls
    for i in range(ball_num):
        if int(ball_pos[i][1]) <= BALL_RADIUS:
            ball_vel[i][1] = - ball_vel[i][1]
        if int(ball_pos[i][1]) >= HEIGHT + 1 - BALL_RADIUS:
            ball_vel[i][1] = -ball_vel[i][1]
    
    #ball collison check on gutters or paddles
    for i in range(ball_num):
        for q in range(2):
            if int(ball_pos[i][0]) + BALL_RADIUS + ball_vel[i][0] >= paddle1_pos[q][0] - PAD_WIDTH and int(ball_pos[i][0]) <= paddle1_pos[q][0] - PAD_WIDTH and\
                 int(ball_pos[i][1]) in range(paddle1_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS, paddle1_pos[q][1] + HALF_PAD_HEIGHT,1):
                ball_vel[i][0] = -abs(ball_vel[i][0])
                ball_vel[i][0] *= 1.2
                ball_vel[i][1] *= 1.2
                reward -= abs(ball_vel[i][0])
            elif int(ball_pos[i][0]) - BALL_RADIUS + ball_vel[i][0] <= paddle1_pos[q][0] + PAD_WIDTH and int(ball_pos[i][0]) >= paddle1_pos[q][0] + PAD_WIDTH and\
                int(ball_pos[i][1]) in range(paddle1_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS, paddle1_pos[q][1] + HALF_PAD_HEIGHT,1):
                ball_vel[i][0] = abs(ball_vel[i][0])
                ball_vel[i][0] *= 1.2
                ball_vel[i][1] *= 1.2
                reward += abs(ball_vel[i][0])
            elif int(ball_pos[i][0]) <= BALL_RADIUS + PAD_WIDTH:
                r_score += 1
                reward -= 10
                ball_init(i)
    
    for i in range(ball_num):
        for q in range(2):
            if int(ball_pos[i][0]) + BALL_RADIUS + ball_vel[i][0] >= paddle2_pos[q][0] - PAD_WIDTH and ball_pos[i][0] <= paddle2_pos[q][0] - PAD_WIDTH and\
                 int(ball_pos[i][1]) in range(paddle2_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS, paddle2_pos[q][1] + HALF_PAD_HEIGHT,1):
                ball_vel[i][0] = -(ball_vel[i][0])
                ball_vel[i][0] *= 1.2
                ball_vel[i][1] *= 1.2
            elif int(ball_pos[i][0]) - BALL_RADIUS + ball_vel[i][0] <= paddle2_pos[q][0] + PAD_WIDTH and ball_pos[i][0] >= paddle2_pos[q][0] + PAD_WIDTH and\
                int(ball_pos[i][1]) in range(paddle2_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS, paddle2_pos[q][1] + HALF_PAD_HEIGHT,1):
                ball_vel[i][0] = abs(ball_vel[i][0])
                ball_vel[i][0] *= 1.2
                ball_vel[i][1] *= 1.2
            elif int(ball_pos[i][0]) >= WIDTH + 1 - BALL_RADIUS - PAD_WIDTH:
                l_score += 1
                ball_init(i)

    #update scores
    myfont1 = pygame.font.SysFont("Comic Sans MS", 20)
    label1 = myfont1.render("Score "+str(l_score), 1, (255,255,0))
    canvas.blit(label1, (50,20))

    myfont2 = pygame.font.SysFont("Comic Sans MS", 20)
    label2 = myfont2.render("Score "+str(r_score), 1, (255,255,0))
    canvas.blit(label2, (470, 20))  

    myfont3 = pygame.font.SysFont("Comic Sans MS", 20)
    label2 = myfont3.render("reward "+str(reward), 1, (255,255,0))
    canvas.blit(label2, (670, 20))  
    
    
#keydown handler
def keydown(event):
    global paddle1_vel, paddle2_vel
    
    if event.key == K_UP:
        paddle2_vel[0] = -8
    elif event.key == K_DOWN:
        paddle2_vel[0] = 8
    # elif event.key == K_w:
    #     paddle1_vel[0] = -8
    # elif event.key == K_s:
    #     paddle1_vel[0] = 8
    elif event.key == K_u:
        paddle2_vel[1] = -8
    elif event.key == K_j:
        paddle2_vel[1] = 8
    # elif event.key == K_y:
    #     paddle1_vel[1] = -8
    # elif event.key == K_h:
    #     paddle1_vel[1] = 8

#keyup handler
def keyup(event):
    global paddle1_vel, paddle2_vel
    
    if event.key in (K_w, K_s):
        # paddle1_vel[0] = 0
        pass
    elif event.key in (K_UP, K_DOWN):
        paddle2_vel[0] = 0
    elif event.key in (K_u, K_j):
        paddle2_vel[1] = 0
    # elif event.key in (K_y, K_h):
        # paddle1_vel[1] = 0

init()

#### PPO begin
import torch
import torch.nn as nn
from torch.distributions import MultivariateNormal
from torch.distributions import Categorical

device = torch.device('cpu')

if(torch.cuda.is_available()): 
    device = torch.device('cuda:0') 
    torch.cuda.empty_cache()

class RolloutBuffer:
    def __init__(self):
        self.actions = []
        self.states = []
        self.logprobs = []
        self.rewards = []
        self.is_terminals = []
    

    def clear(self):
        del self.actions[:]
        del self.states[:]
        del self.logprobs[:]
        del self.rewards[:]
        del self.is_terminals[:]

class ActorCritic(nn.Module):
    def __init__(self, state_dim, action_dim, action_std_init):
        super(ActorCritic, self).__init__()

        
        self.actor = nn.Sequential(
                        nn.Linear(state_dim, 64),
                        nn.ReLU(),
                        nn.Linear(64, 64),
                        nn.ReLU(),
                        nn.Linear(64, action_dim),
                        nn.Softmax(dim=-1)
                    )

        
        # critic
        self.critic = nn.Sequential(
                        nn.Linear(state_dim, 64),
                        nn.ReLU(),
                        nn.Linear(64, 64),
                        nn.ReLU(),
                        nn.Linear(64, 1)
                    )

    def act(self, state):

        
        action_probs = self.actor(state)
        dist = Categorical(action_probs)

        action = dist.sample()
        action_logprob = dist.log_prob(action)
        
        return action.detach(), action_logprob.detach()
    


class PPO:
    def __init__(self, state_dim, action_dim, lr_actor, lr_critic, gamma, K_epochs, eps_clip, action_std_init=0.6):

        self.gamma = gamma
        self.eps_clip = eps_clip
        self.K_epochs = K_epochs

        self.policy = ActorCritic(state_dim, action_dim, action_std_init).to(device)

        self.policy_old = ActorCritic(state_dim, action_dim, action_std_init).to(device)
        self.policy_old.load_state_dict(self.policy.state_dict())
        self.buffer = RolloutBuffer()


    def select_action(self, state):

        with torch.no_grad():
            state = torch.FloatTensor(state).to(device)
            action, action_logprob = self.policy_old.act(state)

        self.buffer.states.append(state)
        self.buffer.actions.append(action)
        self.buffer.logprobs.append(action_logprob)

        return action.item()

    def load(self, checkpoint_path):
        self.policy_old.load_state_dict(torch.load(checkpoint_path, map_location=lambda storage, loc: storage))
        self.policy.load_state_dict(torch.load(checkpoint_path, map_location=lambda storage, loc: storage))
        
ppo_agent = PPO(22, 5, 0, 0, 0, 0, 0, None)
import os
checkpoint_path = ".\\PPO_preTrained\\pong_game\\PPO_pong_game_38_0.pth"
ppo_agent.load(checkpoint_path)

#### PPO end


#game loop
while True:

    draw(window)

    for event in pygame.event.get():
        state = []
        for i in range(ball_num):
            state.append(ball_pos[i][0])
            state.append(ball_pos[i][1])
        state.append(paddle1_pos[0][1])
        state.append(paddle1_pos[1][1])
        action = ppo_agent.select_action(state)
        if action == 1:
            paddle1_vel[0] = 8
        elif action == 2:
            paddle1_vel[0] = -8
        elif action == 3:
            paddle1_vel[1] = 8
        elif action == 4:
            paddle1_vel[1] = -8
        if event.type == KEYDOWN:
            keydown(event)
        elif event.type == KEYUP:
            keyup(event)
        elif event.type == QUIT:
            pygame.quit()
            sys.exit()
            
    pygame.display.update()
    fps.tick(60)