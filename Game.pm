#!/usr/bin/perl 

use strict;

use lib "D:/Projects/Java/SloMo";
use Terrain;

package Game;

my $LEVEL_FILE_NAME="level";

my $OBSTACLE_PENALTY=15;
my $MOVE_BONUS=25;

my @nodes;
my $level=1;
my @visited;
my @toVisit;
my %heuristics;
my %coords;
my @quickestPath;
my %quickPath;
my $movesOnThisTerrain=0;
my $currentMove=0;
my $currentTerrain;
my $score=0;
my %userObstacles;
my $isRunning=0;

sub new
{
    my ($class, $weight) = @_;
    my $self = {};  
    bless $self, $class;
    
    $self->init();
    
    return $self;
}

sub startGame
{
	my ($xx, $xy) = ($coords{"X"}[0],$coords{"X"}[1]);
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	my $cTerrain = $nodes[$xx][$xy];
	$heuristics{$cTerrain}=getHeuristic($cTerrain);
	
	findBestPath();
	
	$currentTerrain = shift @quickestPath;
	$coords{"X"}=$coords{$currentTerrain};
	
	printTerrain();
}

sub nextMove
{	
	my ($xx, $xy) = ($coords{"X"}[0],$coords{"X"}[1]);
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	if($xx==$ex && $xy==$ey)
	{
		print "Level completed in $currentMove moves and got $score points.\n Press 4 for RESTART, 5 for NEXT LEVEL or 9 for EXIT";
		return;
	}
	if($movesOnThisTerrain == $currentTerrain->getWeight())
	{
		$currentTerrain = shift @quickestPath;
		$coords{"X"}=$coords{$currentTerrain};
		$movesOnThisTerrain=0;
	}
	else
	{
		$movesOnThisTerrain++;
	}
	$currentMove++;
	$score+=$MOVE_BONUS;
	printTerrain();
	$isRunning=1;
}

sub restart
{
	resetVars();
	init();
	startGame();
}

sub nextLevel
{
	$level++;
	restart();
}

sub addObstacle
{
	my ($self, $weight, $x, $y) = @_;
	$nodes[$x][$y]->setWeight($weight);
	$score-=$OBSTACLE_PENALTY*$weight;
	
	undef(@visited);
	undef(@toVisit);
	undef(%heuristics);
	undef(@quickestPath);
	undef(%quickPath);
	startGame();
}

sub findBestPath
{
	my ($xx, $xy);
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	do
	{
		($xx, $xy) = ($coords{"X"}[0],$coords{"X"}[1]);
		
		my $cTerrain = $nodes[$xx][$xy];
		push(@visited, $cTerrain);
		if($xx!=$ex || $xy!=$ey)
		{
			$quickPath{$cTerrain}=[];
			addToToVisit($cTerrain);
			moveX();
		}
		else
		{
			@quickestPath = DFS($visited[0]);
		}
	}
	while($xx!=$ex || $xy!=$ey);
}

sub DFS 
{
	my ($cTerrain, @cPath) = @_;
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	my ($cx, $cy) = ($coords{$cTerrain}[0],$coords{$cTerrain}[1]);
	
	push(@cPath, $cTerrain);
	if($cx==$ex && $cy==$ey)
	{
		return @cPath;
	}
	
	foreach my $adjacent(@{$quickPath{$cTerrain}})
	{
		if(grep($adjacent == $_, @visited))
		{
			my @result = DFS($adjacent, @cPath);
			return @result if(@result);
		}
	}
	my @undefArray;
	return @undefArray;
}

sub moveX
{
	$coords{"X"}=$coords{shift @toVisit};
}

sub addToToVisit
{
	my $cTerrain = shift;
	foreach(@{$cTerrain->getAdjacent()})
	{
		if(not exists($heuristics{$_})) 
		{
			push(@toVisit, $_);
			push(@{$quickPath{$cTerrain}}, $_);
			$heuristics{$_}=getHeuristic($_);
		}
	}
	@toVisit = sort {$a->getWeight() + $heuristics{$a} <=> $b->getWeight() + $heuristics{$b}} @toVisit;
}

sub getHeuristic
{
	my $cT=shift;
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	my ($cX, $cY) = ($coords{$cT}[0],$coords{$cT}[1]);
	my $value = abs($ex-$cX) + abs($ey-$cY);
	$heuristics{$nodes[$cX][$cY]} = $value;
	return $value;
}

sub printTerrain
{
	print "======Level $level Move $currentMove========\n";
	my ($xx, $xy) = ($coords{"X"}[0],$coords{"X"}[1]);
	my ($ex, $ey) = ($coords{"E"}[0],$coords{"E"}[1]);
	for(my $i=0; $i<scalar @nodes; $i++)
	{
		for(my $j=0; $j<scalar @{$nodes[$i]}; $j++)
		{
			if($i==$xx && $j==$xy)
			{
				print "X";
			}
			elsif($i==$ex && $j==$ey)
			{
				print "E";
			}
			else
			{
				print $nodes[$i][$j]->getWeight();
			}
		}
		print "\n";
	}
	print "\n";
}

sub resetVars
{
	undef(@nodes);
	undef(@visited);
	undef(@toVisit);
	undef(%heuristics);
	undef(%coords);
	undef(@quickestPath);
	undef(%quickPath);
	$movesOnThisTerrain=0;
	$currentMove=0;
	undef($currentTerrain);
	$score=0;
	undef(%userObstacles);
	$isRunning=0;
}

sub isRunning
{
	return $isRunning;
}

sub init
{	
	if ( -f "$LEVEL_FILE_NAME$level.txt" ) {
		open( FH, "<", "$LEVEL_FILE_NAME$level.txt" );
		my $i=0;
		while (<FH>) {
			chomp;
			if($i==0)
			{
				$coords{"X"}= [split(",")];
				$coords{"startX"} = $coords{"X"};
			}
			elsif($i==1)
			{
				$coords{"E"}= [split(",")];
			}
			else
			{
				my @row=split("");
				my $j=0;
				foreach(@row)
				{
					my $t = new Terrain($_);
					$nodes[$i-2][$j] = $t;
					$coords{$t}=[$i-2, $j];
					$j++;
				}
			}
			$i++;		
		}
		close(FH);	
	}
	else {
		print "$LEVEL_FILE_NAME.$level not found.\n\n";	
	}
	
	for(my $i=0; $i<scalar @nodes; $i++)
	{
		for(my $j=0; $j<scalar @{$nodes[$i]}; $j++)
		{
			$nodes[$i][$j]->addAdjacent($nodes[$i-1][$j]) if $i>0;
			$nodes[$i][$j]->addAdjacent($nodes[$i][$j-1]) if $j>0;
			$nodes[$i][$j]->addAdjacent($nodes[$i+1][$j]) if $i<scalar @nodes-1;
			$nodes[$i][$j]->addAdjacent($nodes[$i][$j+1]) if $j<scalar @{$nodes[$i]}-1;
		}
	}
}	

1;
