import numpy as np
from gym import spaces
import random
import pygame, sys
from pygame.locals import *
import pong_config

class DoublePong:
	WHITE = (255,255,255)
	RED = (255,0,0)
	GREEN = (0,255,0)
	BLACK = (0,0,0)
	PAD_WIDTH = pong_config.PAD_WIDTH
	PAD_HEIGHT = pong_config.PAD_HEIGHT
	BALL_RADIUS = pong_config.BALL_RADIUS
	PAD_SPACE = pong_config.PAD_SPACE
	HALF_PAD_WIDTH = PAD_WIDTH // 2
	HALF_PAD_HEIGHT = PAD_HEIGHT // 2
	ball_num = pong_config.ball_num
	colorlist = [RED] * 50
	action_space = spaces.Discrete(4)
	observation_space = spaces.Box(np.array([np.float32(-320)] * (ball_num * 4 + 4)), np.array([np.float32(pong_config.WIDTH)] * (ball_num * 4 + 4)))
	def __init__(self, WIDTH = pong_config.WIDTH, HEIGHT = pong_config.HEIGHT, ball_num = pong_config.ball_num):
		self.WIDTH = WIDTH
		self.HEIGHT = HEIGHT
		self.ball_num = ball_num
		self.reward = 0
		self.action_space = spaces.Discrete(4)
		observation_high = np.array([np.float32(max(WIDTH, HEIGHT))] * (ball_num * 4 + 4))
		observation_low = np.array([np.float32(-max(WIDTH, HEIGHT))] * (ball_num * 4 + 4))
		self.observation_space = spaces.Box(observation_low, observation_high)
		self.ball_pos = [[0,0]] * ball_num
		self.ball_vel = [[0,0]] * ball_num
		self.paddle1_vel = [0, 0]
		self.paddle2_vel = [0, 0]
		self.paddle1_pos = [[0, 0], [0, 0]]
		self.paddle2_pos = [[0, 0], [0, 0]]
		self.colorlist = [(255,0,0)] * 50
		self.l_score = 0
		self.r_score = 0
		self.first_show = True
		self.counter = 0
		self.horz = 2
		self.vert = -3
		self.defense = 0
		self.reset()
		
	def reset(self):
		# global paddle1_pos, paddle2_pos, paddle1_vel, paddle2_vel,l_score,r_score  # these are floats
		self.paddle1_pos[0] = [DoublePong.HALF_PAD_WIDTH - 1, self.HEIGHT//2]
		self.paddle2_pos[0] = [self.WIDTH +1 - DoublePong.HALF_PAD_WIDTH, self.HEIGHT//2]
		self.paddle1_pos[1] = [DoublePong.HALF_PAD_WIDTH - 1 + DoublePong.PAD_SPACE, self.HEIGHT//2]
		self.paddle2_pos[1] = [self.WIDTH +1 - DoublePong.HALF_PAD_WIDTH - DoublePong.PAD_SPACE, self.HEIGHT//2]
		self.l_score = 0
		self.r_score = 0
		self.counter = 0
		self.reward = 0
		for i in range(self.ball_num):
			self.ball_init(i)
		observation = []
		for i in range(self.ball_num):
			observation.append(self.ball_pos[i][0])
			observation.append(self.ball_pos[i][1])
			observation.append(self.ball_vel[i][0])
			observation.append(self.ball_vel[i][1])
		observation.append(self.paddle1_pos[0][0])
		observation.append(self.paddle1_pos[0][1])
		observation.append(self.paddle1_pos[1][0])
		observation.append(self.paddle1_pos[1][1])
		return observation
	def ball_init(self, id):
		self.ball_pos[id] = [self.WIDTH//2,self.HEIGHT//2]
# 		horz = random.randrange(2,4)
# 		vert = random.randrange(-3,3)
		self.horz = self.horz + 1 if self.horz != 4 else 2
		self.vert = self.horz + 1 if self.horz != 3 else -3
		if self.vert == 0:
			self.vert = self.vert + 1
		self.colorlist[id] = (random.randrange(0,255),random.randrange(0,255),random.randrange(0,255))
		if self.defense == 0:
			self.horz = - self.horz
# 		self.defense = 1 if self.defense == 0 else 0
			
		self.ball_vel[id] = [self.horz,-self.vert]
	def step(self, action):
		observation = []
		reward = 0
		done = False if self.counter < 10800 else True
		info = []
		self.counter += 1
		action += 1
		if action == 1:
			self.paddle1_vel[0] = 8
		elif action == 2:
			self.paddle1_vel[0] = -8
		elif action == 3:
			self.paddle1_vel[1] = 8
		elif action == 4:
			self.paddle1_vel[1] = -8
		
		if self.paddle1_pos[0][1] > DoublePong.HALF_PAD_HEIGHT and self.paddle1_pos[0][1] < self.HEIGHT - DoublePong.HALF_PAD_HEIGHT:
			self.paddle1_pos[0][1] += self.paddle1_vel[0]
		elif self.paddle1_pos[0][1] <= DoublePong.HALF_PAD_HEIGHT and self.paddle1_vel[0] > 0:
			self.paddle1_pos[0][1] += self.paddle1_vel[0]
		elif self.paddle1_pos[0][1] >= self.HEIGHT - DoublePong.HALF_PAD_HEIGHT and self.paddle1_vel[0] < 0:
			self.paddle1_pos[0][1] += self.paddle1_vel[0]

		if self.paddle1_pos[1][1] > DoublePong.HALF_PAD_HEIGHT and self.paddle1_pos[1][1] < self.HEIGHT - DoublePong.HALF_PAD_HEIGHT:
			self.paddle1_pos[1][1] += self.paddle1_vel[1]
		elif self.paddle1_pos[1][1] <= DoublePong.HALF_PAD_HEIGHT and self.paddle1_vel[1] > 0:
			self.paddle1_pos[1][1] += self.paddle1_vel[1]
		elif self.paddle1_pos[1][1] >= self.HEIGHT - DoublePong.HALF_PAD_HEIGHT and self.paddle1_vel[1] < 0:
			self.paddle1_pos[1][1] += self.paddle1_vel[1]
		
		if self.paddle2_pos[0][1] > DoublePong.HALF_PAD_HEIGHT and self.paddle2_pos[0][1] < self.HEIGHT - DoublePong.HALF_PAD_HEIGHT:
			self.paddle2_pos[0][1] += self.paddle2_vel[0]
		elif self.paddle2_pos[0][1] <= DoublePong.HALF_PAD_HEIGHT and self.paddle2_vel[0] > 0:
			self.paddle2_pos[0][1] += self.paddle2_vel[0]
		elif self.paddle2_pos[0][1] >= self.HEIGHT - DoublePong.HALF_PAD_HEIGHT and self.paddle2_vel[0] < 0:
			self.paddle2_pos[0][1] += self.paddle2_vel[0]

		if self.paddle2_pos[1][1] > DoublePong.HALF_PAD_HEIGHT and self.paddle2_pos[1][1] < self.HEIGHT - DoublePong.HALF_PAD_HEIGHT:
			self.paddle2_pos[1][1] += self.paddle2_vel[1]
		elif self.paddle2_pos[1][1] <= DoublePong.HALF_PAD_HEIGHT and self.paddle2_vel[1] > 0:
			self.paddle2_pos[1][1] += self.paddle2_vel[1]
		elif self.paddle2_pos[1][1] >= self.HEIGHT - DoublePong.HALF_PAD_HEIGHT and self.paddle2_vel[1] < 0:
			self.paddle2_pos[1][1] += self.paddle2_vel[1]

		self.paddle1_vel = [0, 0]

		#update ball
		for i in range(self.ball_num):
			self.ball_pos[i][0] += int(self.ball_vel[i][0])
			self.ball_pos[i][1] += int(self.ball_vel[i][1])

		#ball collision check on top and bottom walls
		for i in range(self.ball_num):
			if int(self.ball_pos[i][1]) <= DoublePong.BALL_RADIUS:
				self.ball_vel[i][1] = - self.ball_vel[i][1]
			if int(self.ball_pos[i][1]) >= self.HEIGHT + 1 - DoublePong.BALL_RADIUS:
				self.ball_vel[i][1] = -self.ball_vel[i][1]
		
		#ball collison check on gutters or paddles
		for i in range(self.ball_num):
			for q in range(2):
				if int(self.ball_pos[i][0]) + DoublePong.BALL_RADIUS + self.ball_vel[i][0] >= self.paddle1_pos[q][0] - DoublePong.PAD_WIDTH and int(self.ball_pos[i][0]) <= self.paddle1_pos[q][0] - DoublePong.PAD_WIDTH and\
					int(self.ball_pos[i][1]) >= self.paddle1_pos[q][1] - DoublePong.HALF_PAD_HEIGHT - DoublePong.BALL_RADIUS and int(self.ball_pos[i][1]) <= self.paddle1_pos[q][1] + DoublePong.HALF_PAD_HEIGHT:
					self.ball_vel[i][0] = -abs(self.ball_vel[i][0])
					self.ball_vel[i][0] *= 1.2
					self.ball_vel[i][1] *= 1.2
					reward -= 5 + abs(self.ball_vel[i][0])
				elif int(self.ball_pos[i][0]) - DoublePong.BALL_RADIUS + self.ball_vel[i][0] <= self.paddle1_pos[q][0] + DoublePong.PAD_WIDTH and int(self.ball_pos[i][0]) >= self.paddle1_pos[q][0] + DoublePong.PAD_WIDTH and\
					int(self.ball_pos[i][1]) >= self.paddle1_pos[q][1] - DoublePong.HALF_PAD_HEIGHT - DoublePong.BALL_RADIUS and int(self.ball_pos[i][1]) <= self.paddle1_pos[q][1] + DoublePong.HALF_PAD_HEIGHT:
					self.ball_vel[i][0] = abs(self.ball_vel[i][0])
					self.ball_vel[i][0] *= 1.2
					self.ball_vel[i][1] *= 1.2
					reward += 5 + abs(self.ball_vel[i][0])
				elif int(self.ball_pos[i][0]) <= DoublePong.BALL_RADIUS + DoublePong.PAD_WIDTH:
					self.r_score += 1
					reward -= 10
					self.ball_init(i)
		
		for i in range(self.ball_num):
			for q in range(2):
				if int(self.ball_pos[i][0]) + DoublePong.BALL_RADIUS + self.ball_vel[i][0] >= self.paddle2_pos[q][0] - DoublePong.PAD_WIDTH and self.ball_pos[i][0] <= self.paddle2_pos[q][0] - DoublePong.PAD_WIDTH and\
					random.randrange(1, 20) < 19:
					# int(self.ball_pos[i][1]) >= self.paddle2_pos[q][1] - DoublePong.HALF_PAD_HEIGHT - DoublePong.BALL_RADIUS and int(self.ball_pos[i][1]) <= self.paddle2_pos[q][1] + DoublePong.HALF_PAD_HEIGHT:
					self.ball_vel[i][0] = -abs(self.ball_vel[i][0])
					self.ball_vel[i][0] *= 1.2
					self.ball_vel[i][1] *= 1.2
				elif int(self.ball_pos[i][0]) - DoublePong.BALL_RADIUS + self.ball_vel[i][0] <= self.paddle2_pos[q][0] + DoublePong.PAD_WIDTH and self.ball_pos[i][0] >= self.paddle2_pos[q][0] + DoublePong.PAD_WIDTH and\
					random.randrange(1, 20) < 9:
					# int(self.ball_pos[i][1]) >= self.paddle2_pos[q][1] - DoublePong.HALF_PAD_HEIGHT - DoublePong.BALL_RADIUS and int(self.ball_pos[i][1]) <= self.paddle2_pos[q][1] + DoublePong.HALF_PAD_HEIGHT:
					self.ball_vel[i][0] = abs(self.ball_vel[i][0])
					self.ball_vel[i][0] *= 1.2
					self.ball_vel[i][1] *= 1.2
				elif int(self.ball_pos[i][0]) >= self.WIDTH + 1 - DoublePong.BALL_RADIUS - DoublePong.PAD_WIDTH:
					self.l_score += 1
					self.ball_init(i)
		observation = []
		for i in range(self.ball_num):
			observation.append(self.ball_pos[i][0])
			observation.append(self.ball_pos[i][1])
			observation.append(self.ball_vel[i][0])
			observation.append(self.ball_vel[i][1])
		observation.append(self.paddle1_pos[0][0])
		observation.append(self.paddle1_pos[0][1])
		observation.append(self.paddle1_pos[1][0])
		observation.append(self.paddle1_pos[1][1])
		info = {"l_score":self.l_score, "r_score":self.r_score}
		self.reward += reward
		return [observation, reward, done, info]
	def render(self):
		if self.first_show:
			pygame.init()
			self.window = pygame.display.set_mode((self.WIDTH, self.HEIGHT), 0, 32)
			pygame.display.set_caption('Hello World')
			self.first_show = False
		pygame.event.get()
		self.window.fill(DoublePong.BLACK)
		pygame.draw.line(self.window, self.WHITE, [self.WIDTH // 2, 0],[self.WIDTH // 2, self.HEIGHT], 1)
		pygame.draw.line(self.window, self.WHITE, [DoublePong.PAD_WIDTH, 0],[DoublePong.PAD_WIDTH, self.HEIGHT], 1)
		pygame.draw.line(self.window, self.WHITE, [self.WIDTH - DoublePong.PAD_WIDTH, 0],[self.WIDTH - DoublePong.PAD_WIDTH, self.HEIGHT], 1)
		pygame.draw.circle(self.window, self.WHITE, [self.WIDTH//2, self.HEIGHT//2], 70, 1)
		for i in range(self.ball_num):
			pygame.draw.rect(self.window, self.colorlist[i], [self.ball_pos[i][0]-DoublePong.BALL_RADIUS, self.ball_pos[i][1]-DoublePong.BALL_RADIUS, DoublePong.BALL_RADIUS * 2, DoublePong.BALL_RADIUS * 2], 2)
		pygame.draw.polygon(self.window, DoublePong.GREEN, [[self.paddle1_pos[0][0] - DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[0][1] - DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[0][0] - DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[0][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[0][0] + DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[0][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[0][0] + DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[0][1] - DoublePong.HALF_PAD_HEIGHT]], 0)
		pygame.draw.polygon(self.window, DoublePong.GREEN, [[self.paddle2_pos[0][0] - DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[0][1] - DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[0][0] - DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[0][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[0][0] + DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[0][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[0][0] + DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[0][1] - DoublePong.HALF_PAD_HEIGHT]], 0)
		pygame.draw.polygon(self.window, DoublePong.GREEN, [[self.paddle1_pos[1][0] - DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[1][1] - DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[1][0] - DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[1][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[1][0] + DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[1][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle1_pos[1][0] + DoublePong.HALF_PAD_WIDTH, self.paddle1_pos[1][1] - DoublePong.HALF_PAD_HEIGHT]], 0)
		pygame.draw.polygon(self.window, DoublePong.GREEN, [[self.paddle2_pos[1][0] - DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[1][1] - DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[1][0] - DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[1][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[1][0] + DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[1][1] + DoublePong.HALF_PAD_HEIGHT], [self.paddle2_pos[1][0] + DoublePong.HALF_PAD_WIDTH, self.paddle2_pos[1][1] - DoublePong.HALF_PAD_HEIGHT]], 0)
		#update scores
		myfont1 = pygame.font.SysFont("Comic Sans MS", 20)
		label1 = myfont1.render("Score "+str(self.l_score), 1, (255,255,0))
		self.window.blit(label1, (10,20))

		myfont2 = pygame.font.SysFont("Comic Sans MS", 20)
		label2 = myfont2.render("Score "+str(self.r_score), 1, (255,255,0))
		self.window.blit(label2, (100, 20)) 

		myfont3 = pygame.font.SysFont("Comic Sans MS", 20)
		label2 = myfont3.render("reward "+str(int(self.reward)), 1, (255,255,0))
		self.window.blit(label2, (190, 20))
		pygame.display.update()
	def close(self):
		if not self.first_show:
			pygame.quit()
		
# env = DoublePong()
# fps = pygame.time.Clock()
# while True:
# 	st = env.reset()
# 	done = False
# 	while not done:
# 		action = random.randrange(0,6)
# 		observation, reward, done, info = env.step(action)
# 		env.render()
# 		# fps.tick(60)
