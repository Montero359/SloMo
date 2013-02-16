#!/usr/bin/perl

use strict;

package Terrain;

sub new
{
    my ($class, $weight) = @_;
    my $self = {};
    $self->{weight}=$weight;
    $self->{adjacent}=();
    bless $self, $class;
    return $self;
}

sub addAdjacent
{
	my $self=shift;
	my $t=shift;
	#print "Adding addjacent ".$self->getWeight()." -> ".$t->getWeight()."\n";
	push(@{$self->{adjacent}},$t);
}

sub getAdjacent
{
	my $self=shift;
	return $self->{adjacent};
}

sub isAdjacent
{
	my $self=shift;
	my $terrain=shift;
	foreach(@{$self->{adjacent}})
	{
		if($terrain == $_)
		{
			return 1;
		}
	}
	return 0;
}

sub getWeight
{
	my ($self) = @_;
	#print "getting weight $self->{weight}\n";
	return $self->{weight};
}

sub setWeight
{
	my ($self, $newWeight) = @_;
	$self->{weight}=$newWeight;
}

1;