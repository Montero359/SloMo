#!/usr/bin/perl 

use strict;

use lib "D:/Projects/Java/SloMo";
use Game;

my $START_GAME = 1;
my $ADD_OBSTACLE = 2;
my $NEXT_MOVE=3;
my $RESTART=4;
my $NEXT_LEVEL=5;
my $EXIT=9;

my $game = new Game();

my $userInput;
print "Enter 1 to START a new game, 2 to ADD AN OBSTACLE, 3 to NEXT MOVE, 4 to RESTART, 5 for NEXT LEVEL, 9 to QUIT:";
do
{
	$userInput = <STDIN>;
	chomp($userInput);
	
	if($userInput==$START_GAME)
	{
		$game->startGame();
	}
	elsif($userInput==$ADD_OBSTACLE)
	{
		if($game->isRunning)
		{
			print "You can't add an obstacle when the game is running. Press 4 to RESTART.";
		}
		else
		{
			my $correctInput=0;
			my @inputObstacle;
			do
			{
				print "Enter weight, x and y separeted by space";
				@inputObstacle = split(" ", <STDIN>);
				$correctInput=1 if $inputObstacle[0]>=0 && $inputObstacle[0]<=9 && $inputObstacle[1]>=0 && $inputObstacle[2]>=0;
			}
			while(!$correctInput);
			$game->addObstacle(@inputObstacle);
		}
	}
	elsif($userInput==$NEXT_MOVE)
	{
		$game->nextMove();
	}
	elsif($userInput==$RESTART)
	{
		$game->restart();
		$game->startGame();
	}
	elsif($userInput==$NEXT_LEVEL)
	{
		$game->nextLevel();
	}
	elsif($userInput==$EXIT)
	{
		print "Exiting...";
	}
	else
	{
		print "Uknown command \"$userInput\"";
	}
	
}
while($userInput != $EXIT);