   public static void  checkKeys(PublicKey pub, SecretKey [] sec) throws NoLegalVotes, NoSuchAlgorithmException, NotEnoughTallies, IllegalVote{
	long start, stop;
int votercount=8;
int tallycount=8;
int votecount=3;
	Voter voter; //entity voting
	Tally[] tallies = new Tally[tallycount];//contains the distributed key shares
	Result res;

	Vote[] ciparray = new Vote[votercount]; //array of cipher texts representing the votes
//	Vote[] virtualciparray;// array of cipher texts representing the scaled version of the votes
	DecodingShare[] tallyarray =  new DecodingShare[tallycount];//contains the decoding shares
	BigInteger msg, temp;
        BigInteger result;

	BigInteger n[];
	int i, j;

	String[] vote_names = new String[votecount]; //candidates


	System.out.println ("Generating Votenames...."); //candidates names generation
	for (i = 0; i < votecount; i++)
	    vote_names[i] = "Vote " + i;

	System.out.println ("Generating Keysystem....");

//	trusted = new Trusted (bits, power, hashsize, tallycount, mintallies, 64);//generates the secret key
//	System.out.println ("Election details....");
//        	trusted.produceKeyShares();

//	trusted.MakeSelectionElection ("Gore for president?", vote_names);//generates the public key specific for this setup
//	pub = trusted.GetPublicKey ();//gets the public key shared between the voters

  //      stop = (new Date ()).getTime ();
//	System.out.println ("Key Generation time per tallier (msec):" + (stop-start));


//        CPrivateKey cpriv = new CPrivateKey (bits, 64);
//        CPublicKey cpub = new CPublicKey (cpriv.GetN ());

	System.out.println ("Distributing Secret Keys....");
        for (i = 0; i < tallycount; i++)
	    tallies[i] = new Tally (sec[i],pub);//returns the distributed key share

	System.out.println ("Voting....");
//	start = (new Date ()).getTime ();
	for (i = 0; i < votercount; i++) {
	    voter = new Voter (pub);
	    ciparray[i] = voter.Vote (i % votecount);//vote for arbitrary candidate
        //    ciparray[i] = voter.CVote (i % votecount,cpub);//vote for arbitrary candidate
            System.out.print ("Vote("+i+")= "+i%votecount);
	    System.out.print (".");
	}
//	stop = (new Date ()).getTime ();
//	System.out.println ("\nAvg. Vote time (msec):" + (stop-start)/votercount);



//	System.out.println ("Combining....");
	//start = (new Date ()).getTime ();
	res = new Result (pub);


        temp=ciparray[0].vote;
        for (i = 1; i < votercount; i++) {
            if(Tally.CheckVote (ciparray[i],pub)){
	    temp=res.CombineVotes(temp, ciparray[i].vote);
                System.out.println("T");
           // temp=Result.CombineCVotes(cpub,temp, ciparray[i].vote);
            }
	}
  //      stop = (new Date ()).getTime ();
//	System.out.println ("\nCombining time (msec):" + (stop-start)/votercount);
/*
        System.out.println ("Decrypting....");
	start = (new Date ()).getTime ();
        msg=cpriv.Decrypt(temp);
        stop = (new Date ()).getTime ();
	System.out.println ("Decryption time (msec):" + (stop-start));

 */


        System.out.println ("Tallying....");

   //     start = (new Date ()).getTime ();
	for (i = 0; i < tallycount; i++ ) {
            System.out.print (i);
	    tallyarray[i] = tallies[i].Decode (temp); //get the decoding share
	    System.out.print (".");
	}
//	stop = (new Date ()).getTime ();
//	System.out.println ("\nAvg. Tally time (msec):" + (stop-start)/tallycount);
        msg=res.DistDecryptVotes(tallyarray,temp);


	System.out.println ("Result of election is: " + msg);
	System.out.println ("");

	res.PrintResult (msg);

    }
